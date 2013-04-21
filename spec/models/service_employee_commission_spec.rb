require 'spec_helper'

describe "ServiceSalesOrder" do
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
    @selling_price = "100000"
    @item_name = "Test Item"
    @commission_amount = '10000'
    @item1  = Item.create_object(  {
      :name          =>  "#{@item_name} 1" ,
      :selling_price => @selling_price,
      :commission_amount => @commission_amount 
    })
    @item1.reload 
    
    @item2  = Item.create_object(  {
      :name          =>  "#{@item_name} 2" ,
      :selling_price => @selling_price,
      :commission_amount => @commission_amount
    })
    @item2.reload
    
    @item3  = Item.create_object(  {
      :name          =>  "#{@item_name} 3" ,
      :selling_price => @selling_price,
      :commission_amount => @commission_amount
    })
    @item3.reload
    
    @quantity1 = 10
    @quantity2 = 5
    @quantity3 = 4
    @average_cost_1 = '40000'
    @average_cost_2 = '50000'
    @average_cost_3 = '100000'
    @stock_migration1 = StockMigration.create_object({
      :item_id => @item1.id, 
      :quantity => @quantity1 , 
      :average_cost => @average_cost_1
    })
    @stock_entry1 = @stock_migration1.stock_entry 
    
    @stock_migration2 = StockMigration.create_object({
      :item_id => @item2.id, 
      :quantity => @quantity2 , 
      :average_cost => @average_cost_2
    })
    @stock_entry2 = @stock_migration2.stock_entry 
    
    @stock_migration3 = StockMigration.create_object({
      :item_id => @item3.id, 
      :quantity => @quantity3 , 
      :average_cost => @average_cost_3
    })
    @stock_entry3 = @stock_migration3.stock_entry 
    
    @item1.reload
    @item2.reload
    @item3.reload
    
    
    # => create service
    @service_name = 'First Service'
    @selling_price = '120000'
    @service = Service.create_object({
      :name => @service_name,
      :selling_price => @selling_price
    })
    
    
    # => create service component 
    @service_component_name1 = 'service component 1'
    @commission_amount1 = '12000'
    @service_component1 = ServiceComponent.create_object({
      :name => @service_component_name1 ,
      :service_id => @service.id ,
      :commission_amount => @commission_amount1
    })
    
    @material_usage_name1 = "Material Usage Name"
    @material_usage1 = MaterialUsage.create_object({
      :name =>  @material_usage_name1 ,
      :service_component_id => @service_component1.id ,
      :service_id => @service.id
    })
    
    @mu1_usage_quantity1 = 2 
    @mu1_usage_option1 = UsageOption.create_object({
      :service_component_id => @service_component1.id , 
      :material_usage_id    => @material_usage1.id ,
      :item_id              => @item1.id , 
      :quantity             => @mu1_usage_quantity1
    })
    
    @mu1_usage_quantity2 = 1 
    @mu1_usage_option2 = UsageOption.create_object({
      :service_component_id => @service_component1.id , 
      :material_usage_id    => @material_usage1.id ,
      :item_id              => @item2.id , 
      :quantity             => @mu1_usage_quantity2
    })
    
  end
  
  context "creating service sales order" do 
    before(:each) do
      @so = SalesOrder.create_object( {
        :customer_id => @customer.id  
      } )
      
      @so_entry1 = SalesOrderEntry.create_object(  @so, {
        :entry_id =>   @service.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:service] ,
        :quantity =>  10 ,
        :discount => '0',
        :employee_id => @employee.id  
      })
    end
    
    it 'should create sales order entry' do
      @so_entry1.should be_valid 
    end
    
    it 'should be able to create service_execution' do
      @service_execution = ServiceExecution.create_object({
        :employee_id => @employee.id ,
        :service_component_id => @service_component1.id ,
        :sales_order_entry_id => @so_entry1.id
      })
      @service_execution.should be_valid 
    end
    
    it 'should not create double service execution (for the same service component)' do
      @service_execution = ServiceExecution.create_object({
        :employee_id => @employee.id ,
        :service_component_id => @service_component1.id,
        :sales_order_entry_id => @so_entry1.id 
      })
      @service_execution.should be_valid
      
      @service_execution = ServiceExecution.create_object({
        :employee_id => @employee.id ,
        :service_component_id => @service_component1.id ,
        :sales_order_entry_id => @so_entry1.id
      })
      @service_execution.should_not be_valid
    end
    
    context "confirming the sales order" do
      before(:each) do 
        @service_execution = ServiceExecution.create_object({
          :employee_id => @employee.id ,
          :service_component_id => @service_component1.id,
          :sales_order_entry_id => @so_entry1.id 
        })
        @service_execution.should be_valid
        @so.confirm
        @so_entry1.reload 
        @service_execution.reload 
      end
      
      it 'should confirm so_entry' do
        @so_entry1.is_confirmed.should be_true 
      end
      
      it 'should confirm service execution' do
        @service_execution.is_confirmed.should be_true 
      end
      
      it 'should produce commission @service_execution equal to the service_component' do
        @service_execution.commission_amount.should == @service_component1.commission_amount 
      end
    end
    
  end
end