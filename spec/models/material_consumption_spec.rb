require 'spec_helper'

describe MaterialConsumption do
  before(:each) do
    role = {
      :system => {
        :@administrator => true
      }
    }

    Role.create!(
    :name        => ROLE_NAME[:admin],
    :title       => 'Administrator',
    :description => 'Role for @administrator',
    :the_role    => role.to_json
    )
    @admin_role = Role.find_by_name ROLE_NAME[:admin]
    first_role = Role.first



    @company = Company.create(:name => "Super metal", :address => "Tanggerang", :phone => "209834290840932")
    @admin = User.create_main_user(   :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 

    @admin.set_as_main_user

    # create vendor  => OK 
    @supplier = Supplier.create({
        :name =>"Monkey Crazy", 
        :contact_person =>"", 
        :phone =>"", 
        :mobile =>"", 
        :bbm_pin =>"", 
        :email =>"", 
        :address =>""})
    
    @employee = Employee.create_object( :name => "Si Employee")
    @customer = Customer.create_object(:name => "McDonald Teluk Bitung")
    
    # create item  
    
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
    
  end  
  
  it 'should check validity' do
     
      @service_component1.should be_valid 

      @material_usage1_1.should be_valid

      @mu1_1_usage_option1.should be_valid 
      
      @mu1_1_usage_option2.should be_valid

      @material_usage1_2.should be_valid 

      @mu1_2_usage_option1.should be_valid 

      @mu1_2_usage_option2.should be_valid

      @service_component2.should be_valid

      @material_usage2_1.should be_valid 

      @mu2_1_usage_option1.should be_valid

      @mu2_1_usage_option2.should be_valid

      @material_usage2_2.should be_valid 

      @mu2_2_usage_option1.should be_valid

      @mu2_2_usage_option2.should be_valid 
    
  end
  
  context "creating service sales order" do
    before(:each) do
      
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
    end
    
    it 'should create valid so_entry' do
      @so_entry1.should be_valid 
    end
    
    it 'should create material_consumptions' do
      @so_entry1.material_consumptions.count.should == 4
    end
    
    # it 'should create the first created usage option' do
    #   @so_entry.material_consuptions.order("id ASC").each do |material_consumption|
    #     material_consumption.usage_option_id.should == mu1_1_usage_option1
    #   end
    # end
  end
end
