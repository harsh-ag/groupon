# == Schema Information
#
# Table name: coupons
#
#  id          :integer          not null, primary key
#  order_id    :integer
#  code        :string(255)
#  redeemed_at :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_coupons_on_order_id  (order_id)
#
# Foreign Keys
#
#  fk_rails_68a5ba75f4  (order_id => orders.id)
#

class Coupon < ActiveRecord::Base
  belongs_to :order

  before_create :generate_token

  def random_token
    SecureRandom.urlsafe_base64.to_s
  end

  def generate_token
    loop do
      token_value = random_token
      if !(Coupon.exists?(code: token_value))
        self.code = token_value
        break
      end
    end

  end
end