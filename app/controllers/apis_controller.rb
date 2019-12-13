class ApisController < ApplicationController
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
  before_action :jwt_authenticate_request!

  def test
		@dataJson = { :message => "[Test] Token 인증 되었습니다! :D", :user => current_user }
		render :json => @dataJson, :except => [:id, :created_at, :updated_at, :category]
  end

  def book_mark
		product = HitProduct.find_by(product_id: params[:product_id])
	  
	    if product.nil?
			render json: { errors: ['유효하지 않는 product_id'] }, status: :unauthorized
		
		elsif product != nil	  
			@bookMark = BookMark.find_by(app_user_id: current_user.id, hit_product_id: product.id)

			if @bookMark.nil?
				@bookMarkResult = BookMark.create(app_user_id: current_user.id, hit_product_id: product.id)
				@dataJson = { :message => "북마크가 생성되었습니다.", :book_mark => { :app_user_id => current_user.app_player,
																				  :hit_product_title => BookMark.eager_load(:hit_product).find(@bookMarkResult.id).hit_product.title }
																				 }

				render :json => @dataJson, :except => [:id, :created_at, :updated_at]
			else
				@bookMark.destroy
				render :json => { :message => "북마크가 삭제되었습니다." }
			end
		end
  end
  
  def book_mark_list
	    arr = Array.new
	  
	    uidStack = 1
		@bookMark = BookMark.eager_load(:hit_product).where(app_user_id: current_user.id).each do |t|
			arr.push([t.hit_product.product_id, t.hit_product.title, t.hit_product.date, t.hit_product.view, t.hit_product.comment, t.hit_product.like, t.hit_product.score, t.hit_product.url, uidStack, t.hit_product.imageUrl, t.hit_product.is_sold_out, t.hit_product.dead_check])
			uidStack += 1
		end
	    # @dataJson = {:book_mark => BookMark.eager_load(:hit_product).where(app_user_id: current_user.id) }
	  
	  	@result = Array.new
	    arr.each do |t|
			@result.push(:product_id => t[0], :title => t[1], :dataAgo => "#{time_ago_in_words(t[2])} 전", :view => t[3], :comment => t[4], :like => t[5],:score => t[6], :url => t[7], :uid => t[8], :imageUrl => t[9], :isSoldOut => t[10], :isDeleted => t[11])
		end
	  
	    render :json => { :user => current_user.app_player, :book_mark => @result }
  end
end