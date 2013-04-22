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
    
    resources :customers
    match 'search_customer' => 'customers#search', :as => :search_customer, :method => :get
    
    resources :app_users 
    
    resources :services
    match 'search_service' => 'services#search', :as => :search_service, :method => :get
    
    resources :service_components
    match 'search_service_component' => 'service_components#search', :as => :search_service_component, :method => :get
    
    resources :material_usages 
    resources :usage_options
    
    resources :suppliers 
    match 'search_supplier' => 'suppliers#search', :as => :search_supplier, :method => :get
    
    resources :items
    match 'search_item' => 'items#search', :as => :search_item, :method => :get  
    resources :stock_migrations 
    
    resources :purchase_orders
    match 'confirm_purchase_order' => 'purchase_orders#confirm' , :as => :confirm_purchase_order, :method => :post 
    resources :purchase_order_entries 
    match 'search_purchase_order_entry' => 'purchase_order_entries#search', :as => :search_purchase_order_entries, :method => :get
    
    resources :purchase_receivals 
    match 'confirm_purchase_receival' => 'purchase_receivals#confirm' , :as => :confirm_purchase_receival, :method => :post 
    resources :purchase_receival_entries 
    
    resources :sales_orders 
    match 'confirm_sales_order' => 'sales_orders#confirm' , :as => :confirm_sales_order, :method => :post 
    resources :sales_order_entries
  end
end
