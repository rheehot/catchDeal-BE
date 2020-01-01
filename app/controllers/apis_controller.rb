class ApisController < ApplicationController
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
  before_action :jwt_authenticate_request!

  def test
		@dataJson = { :message => "[Test] Token 인증 되었습니다! :D", :user => { :appPlayerId => current_user.id, :appPlayer => current_user.app_player, :lastTokenGetDate => current_user.last_token } }
		render :json => @dataJson, :except => [:id, :created_at, :updated_at, :category]
  end
	
  def bookmark_combine
  	begin
	    json_params = JSON.parse(request.body.read)
			product = HitProduct.find_by(product_id: json_params["product"]["id"])
		  
	    if product.nil?
				render json: { errors: ['유효하지 않는 product_id'] }, status: :unauthorized
			
			elsif product != nil	  
				@bookMark = BookMark.find_by(app_user_id: current_user.id, hit_product_id: product.id)
	
				if @bookMark.nil?
					@bookMarkResult = BookMark.create(app_user_id: current_user.id, hit_product_id: product.id)
					@dataJson = { :message => "북마크가 생성되었습니다.",
												:bookMark => {
													:userId => current_user.id,
													:hitProductTitle => BookMark.eager_load(:hit_product).find(@bookMarkResult.id).hit_product.title
												}
											}
	
					render :json => @dataJson, :except => [:id, :created_at, :updated_at]
				else
					@bookMark.destroy
					render :json => { :message => "북마크가 삭제되었습니다." }
				end
			end
		rescue
			render json: {errors: ['Invalid Body']}, :status => :bad_request
		end
  end

  def bookmark_create
    json_params = JSON.parse(request.body.read)
		product = HitProduct.find_by(product_id: json_params["product"]["id"])
	  
    if product.nil?
			render json: { errors: ['유효하지 않는 product_id'] }, :status => :bad_request
		
		elsif product != nil	  
			@bookMark = BookMark.find_by(app_user_id: current_user.id, hit_product_id: product.id)

			if @bookMark.nil?
				@bookMarkResult = BookMark.create(app_user_id: current_user.id, hit_product_id: product.id)
				@dataJson = { :message => "북마크가 생성되었습니다.",
											:bookMark => { :userId => current_user.id,
											:hitProductTitle => BookMark.eager_load(:hit_product).find(@bookMarkResult.id).hit_product.title }
										}

				render :json => @dataJson, :except => [:id, :created_at, :updated_at]
			else
				render json: { errors: ['이미 북마크가 존재합니다.'] }, status: :forbidden
			end
		end
  end
	
  def bookmark_destroy
		json_params = JSON.parse(request.body.read)
		product = HitProduct.find_by(product_id: json_params["product"]["id"])
	  
    if product.nil?
			render json: { errors: ['유효하지 않는 product_id'] }, :status => :bad_request
		
		elsif product != nil
			@bookMark = BookMark.find_by(app_user_id: current_user.id, hit_product_id: product.id)

			if @bookMark != nil
				@bookMark.destroy
				render :json => { :message => "북마크가 삭제되었습니다." }
			elsif @bookMark.nil?
				render json: { errors: ['북마크가 존재하지 않습니다.'] }, status: :forbidden
			end
		end
  end
  
  def bookmark_list
		arr = Array.new
		
		orderStack = 1
		@bookMark = BookMark.eager_load(:hit_product).where(app_user_id: current_user.id).each do |t|
			arr.push([orderStack, t.hit_product.product_id, t.hit_product.title, t.hit_product.view, t.hit_product.comment, t.hit_product.like, t.hit_product.score, "#{time_ago_in_words(t.hit_product.date)} 전", t.hit_product.image_url, t.hit_product.is_sold_out, t.hit_product.dead_check, t.hit_product.is_title_changed, t.hit_product.url, t.hit_product.redirect_url])
			orderStack += 1
		end

		@result = Array.new
		arr.each do |t|
			@result.push(:order => t[0], :productId => t[1], :title => t[2], :view => t[3], :comment => t[4], :like => t[5], :score => t[6], :dataAgo => t[7], :imageUrl => t[8], :isSoldOut => t[9], :isDeleted => t[10], :isTitleChanged => t[11], :url => t[12], :shortUrl => t[13], :isBookmark => true)
		end
		
		render :json => { :userId => current_user.id, :bookmark => @result }
  end
end