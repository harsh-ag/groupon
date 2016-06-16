class DealsController < ApplicationController

  def index
    @deals = Deal.live.paginate(page: params[:page])
  end

  def past
    @deals = Deal.past.paginate(page: params[:page])
  end

  def search
    @keyword = params[:search]
    @deals = Deal.search(@keyword).paginate(page: params[:page])
  end

  def show
    #FIXME_AB: make merchant nemat clickable, which should list all deals by same merchant. paginated
    @deal = Deal.published.find_by_id(params[:id])
    if @deal.nil?
      redirect_to deals_path, alert: "No such Deal exists."
    end
  end

end