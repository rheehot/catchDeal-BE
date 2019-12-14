class AuthenticationController < ApplicationController
	
  def authenticate_user
	    json_params = JSON.parse(request.body.read)
	  
		user = AppUser.find_or_create_by(app_player: ["app_player_id"])
		if user.nil?
			render json: {errors: ['Invalid Username/Password']}, status: :unauthorized
		else
			user.update(last_token: Time.zone.now)
			render json: payload(user)
		end
  end

  private

  def payload(user)    
		@token = JWT.encode({ app_user_id: user.id, exp: 6.months.from_now.to_i }, ENV["SECRET_KEY_BASE"])	
		@tree = { :"JWT token" => "Bearer " + @token } 
		 
		return @tree
  end
end