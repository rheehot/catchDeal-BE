class ApisController < ApplicationController
  before_action :jwt_authenticate_request!

  def test
		@dataJson = { :message => "[Test] Token 인증 되었습니다! :D", :user => current_user }
		render :json => @dataJson, :except => [:id, :created_at, :updated_at, :category]
  end

  def book_mark
	# @bookMark = BookMark.find_by(user_id: current_user.id, post_id: params[:post_id]) 
	# if like.nil?
	# 	Like.create(user_id: current_user.id, post_id: params[:post_id]) 
	# else
	# 	@bookMark.destroy
	# end
  end
end