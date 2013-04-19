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
  
  it 'should create all the necessary shite' do
    @service.should be_valid 
    @service_component1.should be_valid 
    @material_usage1.should be_valid 
    @mu1_usage_option1.should be_valid 
    @mu1_usage_option2.should be_valid 
  end
  
  context "creating service sales order" do 
    before(:each) do
      @so = SalesOrder.create_object( {
        :customer_id => @customer.id  
      } )
    end
    
    it 'should create so' do
      @so.should be_valid 
    end
    
    it 'should be allowed to create service sales entry' do
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id =>   @service.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:service] ,
        :quantity =>  1 ,
        :discount => '0',
        :employee_id => @employee.id  
      })
      so_entry.should be_valid
    end
    
    it 'should set the quantity to be always 1' do
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id =>   @service.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:service] ,
        :quantity =>  10 ,
        :discount => '0',
        :employee_id => @employee.id  
      })
      so_entry.should be_valid
      so_entry.quantity.should == 1 
    end
    
    it 'should set several sales_order_entry with the same service (entry_id)' do
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id =>   @service.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:service] ,
        :quantity =>  10 ,
        :discount => '0',
        :employee_id => @employee.id  
      })
      so_entry.should be_valid
      
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id =>   @service.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:service] ,
        :quantity =>  10 ,
        :discount => '0',
        :employee_id => @employee.id  
      })
      so_entry.should be_valid
    end
    
    
    context "post_creation of sales_order_entry" do
      before(:each) do
        @so_entry1 = SalesOrderEntry.create_object(  @so, {
          :entry_id =>   @service.id ,
          :entry_case =>  SALES_ORDER_ENTRY_CASE[:service] ,
          :quantity =>  10 ,
          :discount => '0',
          :employee_id => @employee.id  
        })
        @so_entry1.reload 
      end
      
      it 'should create default material consumption' do
        @so_entry1.material_consumptions.length.should == 1 
      end
      
      it 'should auto-select the first created usage_option' do
        @so_entry1.material_consumptions.first.usage_option_id.should == @mu1_usage_option1.id 
      end
      


      context "confirming the sales_order" do
        before(:each) do
          @material_consumption1 = @so_entry1.material_consumptions.first 
          @item1.reload 
          @initial_ready1 = @item1.ready
          @so.confirm
          @so_entry1.reload 
          @item1.reload 
          @material_consumption1.reload 
        end

        it 'should confirm the sales_order and sales_order_entry' do
          @so.is_confirmed.should be_true 
          @so_entry1.is_confirmed.should be_true 
        end
        
        it 'should deduct item ready' do
          @final_ready1 = @item1.ready 
          diff = @initial_ready1 - @final_ready1 
          diff.should == @material_consumption1.usage_option.quantity 
        end
        
        it 'should confirm material consumption' do
          @material_consumption1.is_confirmed.should be_true 
        end
        
        context "update usage_option post confirm" do
          before(:each) do
            @item1.reload
            @item2.reload 
            @initial_item1_ready = @item1.ready
            @initial_item2_ready = @item2.ready 
            @material_consumption1.update_object({
              :usage_option_id => @mu1_usage_option2.id
            })
            
            @item1.reload
            @item2.reload
          end
          
          it 'should update the material_consumption1' do
            @material_consumption1.errors.size.should ==0 
            @material_consumption1.usage_option_id.should == @mu1_usage_option2.id 
          end
          
          it 'should recover item1 ready' do
            @final_item1_ready = @item1.ready 
            diff = @final_item1_ready - @initial_item1_ready 
            diff.should == @mu1_usage_option1.quantity 
          end
          
          it 'should deduct item2 ready' do
            @final_item2_ready = @item2.ready
            diff = @initial_item2_ready - @final_item2_ready 
            diff.should == @mu1_usage_option2.quantity 
          end
        end
     
        context "destroy material_consumption" do
          before(:each) do
            @item1.reload
            @initial_item1_ready = @item1.ready
            @material_consumption1.delete_object 
            @item1.reload 
          end
          
          it 'should recovert the item1 ready' do
            @final_item1_ready = @item1.ready 
            diff = @final_item1_ready - @initial_item1_ready 
            diff.should == @mu1_usage_option1.quantity
          end
        end
      end
    end
    
    
  end

 

end
