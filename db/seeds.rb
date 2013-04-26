role = {
  :system => {
    :administrator => true
  }
}

# new role for data entry 
new_role_hash = {
  

  # factory 
  :item_receivals => {
    :index => true 
  },
  :template_sales_items => {
    :index => true 
  },
  
  # sales 
  :customers => {
    :index => true 
  },
  :sales_orders => {
    :index => true 
  },
  :deliveries => {
    :index => true 
  },
  :sales_returns => {
    :index => true 
  },
  :guarantee_returns => {
    :index => true 
  },
  
  # payments
  
  :invoices => {
    :index => true 
  },
  :payments => {
    :index => true 
  }
}

# new_role_hash = {
#   :materials => {
#     :index => false
#   }
# }

Role.create!(
:name        => ROLE_NAME[:admin],
:title       => 'Administrator',
:description => 'Role for administrator',
:the_role    => role.to_json
)
admin_role = Role.find_by_name ROLE_NAME[:admin]
first_role = Role.first

data_entry_role = {
  :customers => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_customer => true ,
    :delete_customer => true  
  },
  :sales_orders => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_sales_order => true ,
    :delete_sales_order => true ,
    :confirm_sales_order => true,
    :print_sales_order => true 
  },
      :sales_items => {
        :new => true,
        :create => true, 
        :edit => true, 
        :update_sales_item => true ,
        :delete_sales_item => true ,
        :confirm_sales_item => true,
        :new_derivative => true, 
        :create_derivative => true ,
        :edit_derivative => true,
        :update_derivative => true  
      },
  :pre_production_histories => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_pre_production_history => true ,
    :delete_pre_production_history => true,
    :confirm_pre_production_history => true
  },
  :production_histories => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_production_history => true ,
    :delete_production_history => true,
    :confirm_production_history => true
  },
  :post_production_histories => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_post_production_history => true ,
    :delete_post_production_history => true,
    :confirm_post_production_history => true
  },
  :deliveries => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_delivery => true ,
    :delete_delivery => true,
    :confirm_delivery => true,
    :finalize_delivery => true ,
    :print_delivery => true 
  },
      :delivery_entries => {
        :new => true,
        :create => true, 
        :edit => true, 
        :update_delivery_entry => true ,
        :delete_delivery_entry => true,
        :confirm_delivery_entry => true,
        :edit_post_delivery_delivery_entry => true ,
        :update_post_delivery_delivery_entry => true 
      },
      
  :sales_returns => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_sales_return => true ,
    :delete_sales_return => true,
    :confirm_sales_return => true
  },
      :sales_return_entries => {
        :new => true,
        :create => true, 
        :edit => true, 
        :update_sales_return_entry => true ,
        :delete_sales_return_entry => true 
      },
  
  :guarantee_returns => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_guarantee_return => true ,
    :delete_guarantee_return => true,
    :confirm_guarantee_return => true
  },
      :guarantee_return_entries => {
        :new => true,
        :create => true, 
        :edit => true, 
        :update_guarantee_return_entry => true ,
        :delete_guarantee_return_entry => true 
      },    
   
  :item_receivals => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_item_receival => true ,
    :delete_item_receival => true,
    :confirm_item_receival => true
  },
      :item_receival_entries => {
        :new => true,
        :create => true, 
        :edit => true, 
        :update_item_receival_entry => true ,
        :delete_item_receival_entry => true 
      },
  
  :invoices => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_invoice => true ,
    :delete_invoice => true,
    :confirm_invoice => true,
    :print_invoice => true 
  }, 
  
  :payments => {
    :new => true,
    :create => true, 
    :edit => true, 
    :update_payment => true ,
    :delete_payment => true,
    :confirm_payment => true,
    :print_payment => true 
  },
      :invoice_payments => {
        :new => true,
        :create => true, 
        :edit => true, 
        :update_invoice_payment => true ,
        :delete_invoice_payment => true 
      }
}


data_entry_role = Role.create!(
:name        => ROLE_NAME[:data_entry],
:title       => 'Data Entry',
:description => 'Role for data entry',
:the_role    => data_entry_role.to_json
)


company = Company.create(:name => "Super metal", :address => "Tanggerang", :phone => "209834290840932")
admin = User.create_main_user(   :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 

admin.set_as_main_user
 




customer_1 = Customer.create_object( {
  :name => "Ibu Ani"
} )

customer_2 = Customer.create_object( {
  :name => "Ibu etc"
} )
 
 
if Rails.env.development?
  10.times.each do |x|

    @employee  = Employee.create_object(  {
      :name          =>  "Karyawan #{x}"  
      })
  end


  10.times.each do |x|
    @selling_price = "100000"
    @item_name = "Test Item"
    @commission_amount = '10000'
    @item1  = Item.create_object(  {
      :name          =>  "#{@item_name} #{x+1}" ,
      :selling_price => @selling_price,
      :commission_amount => @commission_amount 
    })

    @quantity = 10
    @average_cost  = '80000'
    @stock_migration1 = StockMigration.create_object({
      :item_id => @item1.id, 
      :quantity => @quantity , 
      :average_cost => @average_cost
    })
  end

  @item1 = Item.all[0]
  @item2 = Item.all[1]
  @item3 = Item.all[2]
  @item4 = Item.all[3]
  @item5 = Item.all[4]
  @item6 = Item.all[5]
  @item7 = Item.all[6]
  @item8 = Item.all[7]

  # => create service
  @service_name = 'First Service'
  @selling_price = '120000'
  @service = Service.create_object({
    :name => @service_name,
    :selling_price => @selling_price
  })


  # => create service component  1 
  @service_component_name1 = 'service component 1'
  @commission_amount1 = '12000'
  @service_component1 = ServiceComponent.create_object({
    :name => @service_component_name1 ,
    :service_id => @service.id ,
    :commission_amount => @commission_amount1
  })

  # create material usage 1 from service_component 1
  @material_usage_name1_1 = "Material Usage Name 1-1"
  @material_usage1_1 = MaterialUsage.create_object({
    :name =>  @material_usage_name1_1 ,
    :service_component_id => @service_component1.id ,
    :service_id => @service.id
  })

  @mu1_1_usage_quantity1 = 2 
  @mu1_1_usage_option1 = UsageOption.create_object({
    :service_component_id => @service_component1.id , 
    :material_usage_id    => @material_usage1_1.id ,
    :item_id              => @item1.id , 
    :quantity             => @mu1_1_usage_quantity1
  })

  @mu1_1_usage_quantity2 = 1 
  @mu1_1_usage_option2 = UsageOption.create_object({
    :service_component_id => @service_component1.id , 
    :material_usage_id    => @material_usage1_1.id ,
    :item_id              => @item2.id , 
    :quantity             => @mu1_1_usage_quantity2
  })

  # create material usage 2 from service_component 1
  @material_usage_name1_2 = "Material Usage Name 1-2"
  @material_usage1_2 = MaterialUsage.create_object({
    :name =>  @material_usage_name1_2 ,
    :service_component_id => @service_component1.id ,
    :service_id => @service.id
  })

  @mu1_2_usage_quantity1 = 2 
  @mu1_2_usage_option1 = UsageOption.create_object({
    :service_component_id => @service_component1.id , 
    :material_usage_id    => @material_usage1_2.id ,
    :item_id              => @item3.id , 
    :quantity             => @mu1_2_usage_quantity1
  })

  @mu1_2_usage_quantity2 = 1 
  @mu1_2_usage_option2 = UsageOption.create_object({
    :service_component_id => @service_component1.id , 
    :material_usage_id    => @material_usage1_2.id ,
    :item_id              => @item4.id , 
    :quantity             => @mu1_2_usage_quantity2
  })



  ####################### Gonna create service_component 2 #############
  ######################################################################

  # => create service component  1 
  @service_component_name2 = 'service component 2'
  @commission_amount2 = '10000'
  @service_component2 = ServiceComponent.create_object({
    :name => @service_component_name2 ,
    :service_id => @service.id ,
    :commission_amount => @commission_amount2
  })

  # create material usage 1 from service_component 1
  @material_usage_name2_1 = "Material Usage Name 2-1"
  @material_usage2_1 = MaterialUsage.create_object({
    :name =>  @material_usage_name2_1 ,
    :service_component_id => @service_component2.id ,
    :service_id => @service.id
  })

  @mu2_1_usage_quantity1 = 2 
  @mu2_1_usage_option1 = UsageOption.create_object({
    :service_component_id => @service_component2.id , 
    :material_usage_id    => @material_usage2_1.id ,
    :item_id              => @item5.id , 
    :quantity             => @mu2_1_usage_quantity1
  })

  @mu2_1_usage_quantity2 = 1 
  @mu2_1_usage_option2 = UsageOption.create_object({
    :service_component_id => @service_component2.id , 
    :material_usage_id    => @material_usage2_1.id ,
    :item_id              => @item6.id , 
    :quantity             => @mu2_1_usage_quantity2
  })

  # create material usage 2 from service_component 1
  @material_usage_name2_2 = "Material Usage Name 2-2 "
  @material_usage2_2 = MaterialUsage.create_object({
    :name =>  @material_usage_name2_2 ,
    :service_component_id => @service_component2.id ,
    :service_id => @service.id
  })

  @mu2_2_usage_quantity1 = 2 
  @mu2_2_usage_option1 = UsageOption.create_object({
    :service_component_id => @service_component2.id , 
    :material_usage_id    => @material_usage2_2.id ,
    :item_id              => @item7.id , 
    :quantity             => @mu2_2_usage_quantity1
  })

  @mu2_2_usage_quantity2 = 1 
  @mu2_2_usage_option2 = UsageOption.create_object({
    :service_component_id => @service_component2.id , 
    :material_usage_id    => @material_usage2_2.id ,
    :item_id              => @item8.id , 
    :quantity             => @mu2_2_usage_quantity2
  })
  @so = SalesOrder.create_object( {
    :customer_id => Customer.first.id 
  } )


  @so_entry1 = SalesOrderEntry.create_object(  @so, {
    :entry_id =>   Service.first.id  ,
    :entry_case =>  SALES_ORDER_ENTRY_CASE[:service] ,
    :quantity =>  10 ,
    :discount => '0',
    :employee_id => Employee.first.id  
  })

  @so_entry1 = SalesOrderEntry.create_object(  @so, {
    :entry_id =>   Service.first.id  ,
    :entry_case =>  SALES_ORDER_ENTRY_CASE[:service] ,
    :quantity =>  10 ,
    :discount => '0',
    :employee_id => Employee.first.id  
  })
end
