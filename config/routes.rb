Ateng::Application.routes.draw do
  devise_for :users
  root :to => 'home#extjs'
  namespace :api do
    devise_for :users
    match 'authenticate_auth_token' => 'sessions#authenticate_auth_token', :as => :authenticate_auth_token
    match 'update_password' => "passwords#update" , :as => :update_password, :method => :put
  end
 
end
