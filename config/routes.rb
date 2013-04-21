Ateng::Application.routes.draw do
  devise_for :users
  root :to => 'home#extjs'
  
  
  namespace :api do
    devise_for :users
    match 'authenticate_auth_token' => 'sessions#authenticate_auth_token', :as => :authenticate_auth_token
    match 'update_password' => "passwords#update" , :as => :update_password, :method => :put
    
    match 'search_role' => 'roles#search', :as => :search_role, :method => :get
    
    
    resources :employees
    match 'search_employee' => 'employees#search', :as => :search_employee, :method => :get
    
    resources :app_users 
    
    resources :services
    match 'search_service' => 'services#search', :as => :search_service, :method => :get
    
    resources :service_components
    match 'search_service_component' => 'service_components#search', :as => :search_service_component, :method => :get
  end
end
