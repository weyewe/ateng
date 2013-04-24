require 'spec_helper'

describe ServiceExecution do
  before(:each) do
    role = {
      :system => {
        :administrator => true
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
    @employee2 = Employee.create_object( :name => "Si Employee 2")
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


################################################################
################################################################
################################################################   
    # => create service component 
    @service_component_name1 = 'service component 1'
    @commission_amount1 = '12000'
    @service_component1 = ServiceComponent.create_object({
      :name => @service_component_name1 ,
      :service_id => @service.id ,
      :commission_amount => @commission_amount1
    })
    
    
    # creating the first material usage 
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
    
    
    # creating the second material usage 
    
    @material_usage_name2 = "Material Usage Name 2 "
    @material_usage2 = MaterialUsage.create_object({
      :name =>  @material_usage_name2 ,
      :service_component_id => @service_component1.id ,
      :service_id => @service.id
    })
    
    @mu2_usage_quantity1 = 1 
    @mu2_usage_option1 = UsageOption.create_object({
      :service_component_id => @service_component1.id , 
      :material_usage_id    => @material_usage2.id ,
      :item_id              => @item1.id , 
      :quantity             => @mu2_usage_quantity1
    })
    
    @mu2_usage_quantity2 = 2
    @mu2_usage_option2 = UsageOption.create_object({
      :service_component_id => @service_component1.id , 
      :material_usage_id    => @material_usage2.id ,
      :item_id              => @item2.id , 
      :quantity             => @mu2_usage_quantity2
    })
    
################################################################
################################################################
################################################################
  #service_component 2   
  # => create service component 
  @service_component_name2 = 'service component 2'
  @commission_amount2 = '15000'
  @service_component2 = ServiceComponent.create_object({
    :name => @service_component_name2 ,
    :service_id => @service.id ,
    :commission_amount => @commission_amount2
  })
  
  
  # creating the first material usage 
  @material_usage_name2_1= "Material Usage Name"
  @material_usage2_1 = MaterialUsage.create_object({
    :name =>  @material_usage_name2_1 ,
    :service_component_id => @service_component2.id ,
    :service_id => @service.id
  })
  
  @mu2_usage_quantity1 = 1
  @mu2_usage_option1 = UsageOption.create_object({
    :service_component_id => @service_component2.id , 
    :material_usage_id    => @material_usage2_1.id ,
    :item_id              => @item1.id , 
    :quantity             => @mu2_usage_quantity1
  })
  
  @mu2_usage_quantity2 = 2
  @mu2_usage_option2 = UsageOption.create_object({
    :service_component_id => @service_component2.id , 
    :material_usage_id    => @material_usage2_1.id ,
    :item_id              => @item2.id , 
    :quantity             => @mu2_usage_quantity2
  })
  
  
  # creating the second material usage 
  
  @material_usage_name2_2 = "Material Usage Name 2 "
  @material_usage2_2 = MaterialUsage.create_object({
    :name =>  @material_usage_name2_2 ,
    :service_component_id => @service_component2.id ,
    :service_id => @service.id
  })
  
  @mu2_usage_quantity2 = 1 
  @mu2_usage_option2 = UsageOption.create_object({
    :service_component_id => @service_component2.id , 
    :material_usage_id    => @material_usage2_2.id ,
    :item_id              => @item1.id , 
    :quantity             => @mu2_usage_quantity2
  })
  
  @mu2_usage_quantity2 = 2
  @mu2_usage_option2 = UsageOption.create_object({
    :service_component_id => @service_component2.id , 
    :material_usage_id    => @material_usage2_2.id ,
    :item_id              => @item2.id , 
    :quantity             => @mu2_usage_quantity2
  })
  
  
  
  
################################################################
################################################################
################################################################
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
  
  it "if the sales_order is not confirmed, it should not auto create commission (even if there is employee_id)" do
    @so_entry1.service_executions.each do |service_execution|
      service_execution.update_object({
        :employee_id => @employee.id ,
        :service_component_id => service_execution.service_component_id 
      })
      
      service_execution.commission.should be_nil 
      service_execution.employee_id.should == @employee.id 
  
    end
  end
  
  it 'should delete the associated material_consumption on delete' do
    @so_entry1.service_executions.each do |service_execution| 
      service_execution_id = service_execution.id
      service_execution_class_string  = service_execution.class.to_s
      service_execution.delete_object 
      
      # Commission.where(:commissionable_type => service_execution_class_string, :commissionable_id =>service_execution_id ).count.should ==0  
      MaterialConsumption.where(:service_execution_id => service_execution_id ).count.should == 0 
    end
  end
  
  context "post sales order confirmation" do
    before(:each) do 
      @so.confirm 
      @so_entry1.reload 
    end
    
  
    context "delete service_execution post confirm" do
      
      it 'should delete the associated material_consumption and commission' do
        @so_entry1.service_executions.each do |service_execution| 
          service_execution_id = service_execution.id
          service_execution_class_string  = service_execution.class.to_s
          service_execution.delete_object 
          
          Commission.where(:commissionable_type => service_execution_class_string, :commissionable_id =>service_execution_id ).count.should ==0  
          MaterialConsumption.where(:service_execution_id => service_execution_id , :is_deleted => false ).count.should == 0 
        end
      end
    end
    
    context "add employee_id post confirm " do
      before(:each) do
        @first_service_execution = @so_entry1.service_executions.first 
        
        @first_service_execution.update_object({
          :service_component_id => @first_service_execution.service_component_id ,
          :employee_id => @employee.id
        })
        @first_service_execution.reload 
      end
      
      it 'should auto generate commission' do
        @first_service_execution.commission.should be_valid 
      end
    end

    context "add service_execution post_confirm" do
      before(:each) do
        @so_entry1.service_executions.each do |service_execution| 
          service_execution.delete_object 
        end
        @initial_materal_consumption_count = @so_entry1.active_material_consumptions.count 
        @initial_service_execution_count = @so_entry1.active_service_executions.count 
        
        @service_component = @so_entry1.sellable.service_components.first 
        @service_execution = ServiceExecution.create_object({
          :service_component_id => @service_component.id , 
          :employee_id => @employee.id , 
          :sales_order_entry_id => @so_entry1.id 
        })
        @service_execution.reload 
      end
      
      it 'should empty out the service_execution and material_consumption' do
        @initial_materal_consumption_count.should == 0 
        @initial_service_execution_count.should == 0 
      end
      
      it 'should create service_execution + auto_confirm' do
        @service_execution.should be_valid 
        @service_execution.is_confirmed.should be_true 
        
        @service_execution.commission.should be_valid 
        # @service_execution.commission.is_confirmed.should be_true 
        
        @service_execution.material_consumptions.count.should_not == 0 
        @service_execution.material_consumptions.count.should == @service_execution.service_component.material_usages.count 
      end
      
      it 'should auto create the stock_mutation from the associated material_consumption' do
        @service_execution.material_consumptions.each do |material_consumption|
          material_consumption.is_confirmed.should be_true 
          
          StockMutation.where(
            :source_document_entry_id => material_consumption.id , 
            :source_document_entry => material_consumption.class.to_s
          ).count.should == 1 
        end
      end
   
      context "change employee, service_component stays the same" do
        before(:each) do
          @new_service_component = @so_entry1.sellable.service_components.last
          @new_service_component.id.should_not == @service_component.id  
          
          @service_execution.update_object({
            :employee_id => @employee2.id ,
            :service_component_id => @service_execution.service_component_id 
          })
        end
        
        it 'should change the commission receiver' do
          @service_execution.commission.employee_id.should == @employee2.id 
        end
      end
      
      context "preserve employee, service component is changed" do
        before(:each) do
          @new_service_component = @so_entry1.sellable.service_components.last
          @new_service_component.id.should_not == @service_component.id  
          
          @material_consumption_id_list = @service_execution.material_consumptions.collect {|x| x.id }
          
          @service_execution.update_object({
            :employee_id => @service_execution.commission.employee_id, 
            :service_component_id => @new_service_component.id 
          })
        end
        
        it 'should delete all the past material consumption' do
          MaterialConsumption.where(:id => @material_consumption_id_list , :is_deleted => false).count.should == 0 
          MaterialConsumption.where(:id => @material_consumption_id_list , :is_deleted => true).count.should == @material_consumption_id_list.length 
        end
      end
    
    end
    
  end
end
