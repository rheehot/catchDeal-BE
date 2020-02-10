class ApisController < ApplicationController
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
  include HitProductsHelper
  before_action :jwt_authenticate_request!

  def test
		@dataJson = { :message => "[Test] Token 인증 되었습니다! :D", :user => { :appPlayerId => current_user.id, :appPlayer => current_user.app_player, :lastTokenGetDate => current_user.last_token } }
		render :json => @dataJson, :except => [:id, :created_at, :updated_at, :category]
  end
end
