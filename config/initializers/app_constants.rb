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



# Application constants: FIFO inventory costing 

STOCK_ENTRY_USAGE_CASE = {
  # => 0-199 == addition 
    # => 0-9 == internal addition
  :stock_migration => 0 , 
  :stock_adjustment =>1,
  :scrap => 2,  # broken 
  :stock_conversion =>3, 
  :stock_adjustment => 4 , 
  :purchase_receival => 5, 


    # => 10-19 == related to vendor 
  :purchase => 10 ,  
  :purchase_return => 11,

    # => 20-29 == related to sales to customer  
  :sales => 20 ,
  :sales_return => 21 

} 

STOCK_ENTRY_USAGE = {
  :delivery         => 1,
  :stock_adjustment => 2, 
  :in_house_repair  => 3 
}

MUTATION_CASE = {
  :stock_migration => 0, 
  :sales_order => 1 ,
  :stock_conversion_source => 2 ,
  :scrap_item => 3,  # ready item -> scrap item
  :purchase_receival => 4 ,
  
  :stock_adjustment => 33 ,
   # deduction from now on
  
  :delivery => 34,
  :delivery_lost => 35,
  :delivery_returned => 36
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