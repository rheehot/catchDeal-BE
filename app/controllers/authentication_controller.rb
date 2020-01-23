class AuthenticationController < ApplicationController
	
  def authenticate_user
    begin
    	json_params = JSON.parse(request.body.read)

    	user = AppUser.find_or_create_by(app_player: json_params["auth"]["appPlayerId"])
			if user.nil?
				render json: {errors: ['Invalid Player Id']}, status: :unauthorized
			else
				user.update(last_token: Time.zone.now)
				render json: payload(user)
			end
	  rescue
	  	render json: {errors: ['Invalid Player Id22']}, status: :unauthorized
	  end
  end

  private

  def payload(user)    
		@token = JWT.encode({ app_user_id: user.id, exp: 6.months.from_now.to_i }, ENV["SECRET_KEY_BASE"])
		# @token = JWT.encode({ app_user_id: user.id, exp: 1.minutes.from_now.to_i }, ENV["SECRET_KEY_BASE"])
		@tree = { "token" => @token } 
		 
		return @tree
  end
end