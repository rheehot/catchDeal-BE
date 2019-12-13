class ApisController < ApplicationController
  before_action :jwt_authenticate_request!

  def test
		@dataJson = { :message => "[Test] Token 인증 되었습니다! :D", :user => current_user }
		render :json => @dataJson, :except => [:id, :created_at, :updated_at, :category]
  end

  def book_mark_create
		product = HitProduct.find_by(title: params[:hit_product_article])
		@bookMark = BookMark.find_by(app_user_id: current_user.id, hit_product_id: product.id)
		
		if @bookMark.nil?
			BookMark.create(app_user_id: current_user.id, hit_product_id: product.id) 
		else
			@bookMark.destroy
		end
  end
  
  def book_mark_list
		
  end
end