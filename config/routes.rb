Rails.application.routes.draw do  
  root 'hit_products#index'
  
  ## 앱 기본통신 URI
  get 'hit_products/index'
  get 'hit_products/condition'
  get 'hit_products/web_products_list' => "hit_products#web_products_list"
  get 'hit_products/rank'
  get 'hit_products/search'
  
  ## JWT 토큰 생성 및 테스트
  post 'auth_user' => 'authentication#authenticate_user'
  get 'apis/test'
  
  ## 북마크
  post 'apis/book_mark_combine'
  post 'apis/book_mark_create'
  delete 'apis/book_mark_destroy'
  get 'apis/book_mark_list'
  
  resources :notices
  get '/notice.json' => 'notices#index_json'
	
  devise_for :users
	
  authenticate :user, lambda { |u| u.admin? } do
    begin
      get '/welcome' => 'homes#index'
      mount RailsAdmin::Engine => '/popstar/admin', as: 'rails_admin'
    rescue
      redirect_to new_user_session_path
    end
  end
end
