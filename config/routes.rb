Rails.application.routes.draw do
  root 'homes#index'

  ## 렌더 페이지
  get 'homes/index'

  # ------------------------------------ v 1.1 ---------------------------------------------
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

  ## 통신 테스트
  get 'apis/test' => "apis/test"
  
  ## 푸쉬알람
  post 'send-pushalarm' => "apis#send_pushalarm"

  ## 북마크
  post 'book_mark_combine' => 'apis#bookmark_combine'
  post 'bookmark-combine' => 'apis#bookmark_combine'

  post 'book_mark_create' => 'apis#bookmark_create'
  post 'bookmark-create' => 'apis#bookmark_create'

  delete 'book_mark_destroy' => 'apis#bookmark_destroy'
  delete 'bookmark-destroy' => 'apis#bookmark_destroy'

  get 'book_mark_list' => 'apis#bookmark_list'
  get 'bookmark-list' => 'apis#bookmark_list'
  
  get 'bookmark-product-list' => 'apis#bookmark_product_list'
  
  ## 키워드 알람
  patch 'keyword-config' => 'apis#keyword_config'
  get 'keyword-user-status' => 'apis#keyword_user_status'
  post 'keyword-combine' => 'apis#keyword_combine'
  post 'keyword-create' => 'apis#keyword_create'
  delete 'keyword-destroy' => 'apis#keyword_destroy'
  get 'keyword-pushalarm-list' => 'apis#keyword_pushalarm_list'
  # ------------------------------------ v 1.1 ---------------------------------------------
  
  
  
  # ------------------------------------ v 2.0 ---------------------------------------------
  namespace :api do
    namespace :v2 do
      resources :keyword_pushalarms, :only => [:index, :create, :destroy], path: "keyword-pushalarms"
      resource :keyword_pushalarms, :except => [:index, :show, :new, :create, :edit, :update], path: "keyword-pushalarms" do
        post 'send-pushalarm' => 'keyword_pushalarms#send_pushalarm'
        patch 'user-config' => 'keyword_pushalarms#user_config'
        get 'user-status' => 'keyword_pushalarms#status'
        post 'combine' => 'keyword_pushalarms#combine'
        get 'test' => 'keyword_pushalarms#test'
      end
      
      resource :bookmarks, :only => [:index, :create, :destroy] do
        post 'combine' => 'bookmarks#combine'
      end
    end
  end
  # ------------------------------------ v 2.0 ---------------------------------------------
  
  ## 공지사항
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
