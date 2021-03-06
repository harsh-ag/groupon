# == Schema Information
#
# Table name: deals
#
#  id                   :integer          not null, primary key
#  title                :string(255)      not null
#  description          :text(65535)
#  min_qty              :integer
#  max_qty              :integer
#  start_time           :datetime
#  expire_time          :datetime
#  price                :decimal(8, 2)
#  max_qty_per_customer :integer
#  instructions         :text(65535)
#  publishable          :boolean          default(FALSE)
#  category_id          :integer          not null
#  merchant_id          :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  sold_quantity        :integer          default(0)
#  lock_version         :integer          default(0)
#  processed            :boolean          default(FALSE)
#  notified             :boolean          default(FALSE)
#
# Indexes
#
#  index_deals_on_category_id  (category_id)
#  index_deals_on_merchant_id  (merchant_id)
#
# Foreign Keys
#
#  fk_rails_6b084cd147  (category_id => categories.id)
#  fk_rails_bed9e08b8f  (merchant_id => merchants.id)
#

class Deal < ActiveRecord::Base
  DESCRIPTION_MIN_LENGTH = 10
  MINIMUM_PRICE = 0.01
  MINIMUM_MIN_QTY = 1
  MINIMUM_MAX_QTY_PER_CUSTOMER = 1


  self.per_page = 10

  validates :title, presence: true
  validates :category, presence: true
  validates :merchant, presence: true
  with_options if: "publishable?" do |deal|

    deal.validates :description, length: {
      minimum: DESCRIPTION_MIN_LENGTH,
      tokenizer: lambda { |str| str.split(/\s+/)},
      too_short: "must have at least #{ DESCRIPTION_MIN_LENGTH } words"
    }
    deal.validates :min_qty, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: MINIMUM_MIN_QTY }
    deal.validates :sold_quantity, numericality: { only_integer: true, less_than_or_equal_to: ->(deal) { deal.max_qty } }, if: :max_qty?
    deal.validates :start_time, presence: true
    deal.validates :expire_time, presence: true
    deal.validates :price, presence: true, numericality: { greater_than_or_equal_to: MINIMUM_PRICE }
    deal.validates :instructions, presence: true
    deal.validates_associated :locations
    deal.validates_associated :deal_images
    deal.validates_with StartTimeValidator, unless: ->(deal) { deal.deal_processing? || deal.deal_was_notified? }
    deal.validates_with ExpireTimeValidator
    deal.validates_with ImageValidator
    deal.validates_with LocationValidator
  end
  validates :max_qty, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: ->(deal) { deal.min_qty } }, if: ("publishable? && min_qty?")
  validates :max_qty_per_customer, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: MINIMUM_MAX_QTY_PER_CUSTOMER, less_than_or_equal_to: ->(deal) { deal.max_qty }}, if: ("publishable? && max_qty? ")
  
  scope :published, -> { where(publishable: true) }
  scope :live, -> (time = Time.current){ published.where("start_time <= ?", time).where("? <= expire_time ", time) }
  scope :past, -> (time = Time.current){ published.where("? > expire_time", time) }
  scope :search, ->(keyword) { published.includes(:locations).where("lower(title) LIKE ? OR lower(locations.city) LIKE ?","%#{keyword.downcase}%", "%#{keyword.downcase}%" ).references(:locations)}
  scope :processed, -> { where(processed: true ) }
  scope :not_processed, -> { where.not(processed: true) }
  scope :for_coupon_processing, -> { past.not_processed.joins(:orders).group("orders.deal_id").having("sum(orders.quantity) >= deals.min_qty") }
  scope :for_refund_processing, -> { past.not_processed.joins(:orders).group("orders.deal_id").having("sum(orders.quantity) < deals.min_qty") }
  scope :successfully_expired, -> { past.processed.where('min_qty <= sold_quantity') }

  belongs_to :category
  belongs_to :merchant
  has_many :locations, dependent: :destroy, validate: false
  has_many :deal_images, dependent: :destroy, validate: false
  has_many :orders, dependent: :restrict_with_error
  has_many :coupons, through: :orders

  accepts_nested_attributes_for :deal_images, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :locations, allow_destroy: true, reject_if: :all_blank

  before_validation :check_if_deal_can_be_updated?, if: "publishable? && !deal_was_notified?", unless: :deal_processing?

  def publish
    update(publishable: true)
  end

  def unpublish
    update(publishable: false)
  end

  def live?
    start_time && Time.current.between?(start_time, expire_time)
  end

  def expired?
    expire_time && expire_time < Time.current
  end

  def sold_out?
    sold_quantity >= max_qty
  end

  def quantity_available
    max_qty - sold_quantity
  end

  def increase_sold_qty_by(quantity)
    updated_sold_quantity = sold_quantity + quantity
    update_attribute(:sold_quantity, updated_sold_quantity)
  end

  def remaining_quantity_to_activate
    min_qty - sold_quantity
  end

  def deal_processing?
    if changes
      processed_was == false && processed == true
    end
  end

  def deal_was_notified?
    if changes
      notified_was == false && notified == true
    end
  end

  private

  def check_if_deal_can_be_updated?
    if expired?
      errors[:base] << "Expired deal cannot be updated."
      false
    elsif live?
      errors[:base] << "Live Deals cannot be updated."
      false
    end
  end

end
