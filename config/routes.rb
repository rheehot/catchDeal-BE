Rails.application.routes.draw do
  root 'homes#index'

  ## 렌더 페이지
  get 'homes/index'

  ## 앱 기본통신 URI
  get 'hit_products/index' => 'hit_products#index'
  get 'hit-products/index' => 'hit_products#index'

  get 'hit_products/condition' => 'hit_products#condition'
  get 'hit-products/condition' => 'hit_products#condition'

  get 'hit_products/web_products_list' => "hit_products#web_products_list"
  get 'hit-products/web-products-list' => "hit_products#web_products_list"

  get 'hit_products/rank' => 'hit_products#rank'
  get 'hit-products/rank' => 'hit_products#rank'

  get 'hit_products/search' => 'hit_products#search'
  get 'hit-products/search' => 'hit_products#search'

  ## JWT 토큰 생성 및 테스트
  post 'auth_user' => 'authentication#authenticate_user'
  post 'auth-user' => 'authentication#authenticate_user'

  get 'apis/test' => "apis/test"

  ## 북마크
  post 'book_mark_combine' => 'apis#bookmark_combine'
  post 'bookmark-combine' => 'apis#bookmark_combine'

  post 'book_mark_create' => 'apis#bookmark_create'
  post 'bookmark-create' => 'apis#bookmark_create'

  delete 'book_mark_destroy' => 'apis#bookmark_destroy'
  delete 'bookmark-destroy' => 'apis#bookmark_destroy'

  get 'book_mark_list' => 'apis#bookmark_list'
  get 'bookmark-list' => 'apis#bookmark_list'

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
