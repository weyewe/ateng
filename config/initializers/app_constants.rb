ROLE_NAME = {
  :admin => "admin",
  :data_entry => "dataentry"
}

SALES_ORDER_ENTRY_CASE = {
  :item =>  1,  
  :service => 2 
}

# => TIMEZONE ( for 1 store deployment. For multitenant => different story) 
UTC_OFFSET = 7 
LOCAL_TIME_ZONE = "Jakarta" 

EXT_41_JS = 'https://s3.amazonaws.com/weyewe-extjs/41/ext-all.js'


 
STOCK_ENTRY_USAGE = {
  :delivery         => 1,
  :stock_adjustment => 2, 
  :in_house_repair  => 3 
}

MUTATION_CASE = {

  
  :stock_migration => 0, 
  :stock_adjustment_addition => 1, 
  :stock_conversion_target => 2,
  :purchase_receival => 3, 
  :sales_return => 4, 
  
  :stock_adjustment_deduction => 51, 
  :stock_conversion_usage => 52, 
  :sales_item_usage => 53,
  :sales_service_usage => 54 

}

MUTATION_STATUS = {
  :deduction  => 1 ,
  :addition => 2 
}

ITEM_STATUS = {
  :ready => 1 , 
  :scrap => 2, 
  :ordered => 3 , # from the supplier , but hasn't arrived at destination
  :sold => 4 ,  # to the customer, hasn't even left the warehouse 
  :on_delivery => 5  # to the customer. has left the warehouse. but not yet  # do they need this info? no idea
}