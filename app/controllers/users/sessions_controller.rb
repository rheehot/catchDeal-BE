# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  
  private
  def respond_with(resource, _opts = {})
    if request.post?
    	render json: resource
	end
  end

  def respond_to_on_destroy
	if request.delete?
	    render json: "complete Log Out"
	end
  end
	
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
