class HomesController < ApplicationController
  def index
    @hitList = HitProduct.order("date DESC").limit(5)
  end
end
