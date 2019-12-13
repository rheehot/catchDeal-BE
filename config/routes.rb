Rails.application.routes.draw do  
  root 'hit_products#index'
  
  get 'hit_products/index'
  get 'hit_products/condition'
  get 'hit_products/web_products_list' => "hit_products#web_products_list"
  # get 'hit_products/clien'
  # get 'hit_products/ppom'
  # get 'hit_products/ruliweb'
  # get 'hit_products/deal_ba_da'
  get 'hit_products/rank'
  get 'hit_products/search'
  
  resources :notices
  get '/notice.json' => 'notices#index_json'
	
  devise_for :users
  post 'auth_user' => 'authentication#authenticate_user'
  get 'apis/test'
  post 'apis/book_mark'
  post 'apis/book_mark_list'
	
  authenticate :user, lambda { |u| u.admin? } do
    begin
      get '/welcome' => 'homes#index'
      mount RailsAdmin::Engine => '/popstar/admin', as: 'rails_admin'
    rescue
      redirect_to new_user_session_path
    end
  end
end
