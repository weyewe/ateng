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
      
      it 'should create corresponding service_execution(s)' do
        @so_entry1.service_executions.count.should == 1 
      end
      
      it 'should create default material consumption' do
        sum = 0
        @so_entry1.service_executions.each do |service_execution|
          service_execution.service_component.material_usages.where(:is_deleted => false ).each do |material_usage|
            if not material_usage.first_available_option.nil?
              sum += 1 
            end
          end
        end
        
        @so_entry1.material_consumptions.length.should == sum 
      end
      
      

      it 'should auto-select the first created usage_option' do
        @so_entry1.material_consumptions.order("id ASC").first.usage_option_id.should == @mu1_usage_option1.id 
      end
       
       
       
      # before confirmation => auto create the service_execution and material_consumption 
      
      it 'should not create any commission on the auto-created service_execution' do
        @so_entry1.active_service_executions.should_not == 0 
        @so_entry1.active_service_executions.each do |service_execution|
          service_execution.commission.should be_nil 
        end
      end
      
      context "confirming sales order before assigning employee to service_execution" do
        before(:each) do 
          @so.confirm
          @so_entry1.reload
        end
        
        it 'should not create commissions' do
          @so_entry1.active_service_executions.each do |service_execution|
            service_execution.commission.should be_nil 
          end
        end
      end
       
      context "confirming sales_order after assigning employee to service execution" do
        before(:each) do
          
          @so_entry1.active_service_executions.each do |service_execution|
            service_execution.update_object({
              :employee_id =>  @employee.id ,
              :service_component_id => service_execution.service_component_id 
            })
          end
          
          @so_entry1.reload 
          
          @service_execution_soe1 = @so_entry1.active_service_executions.first 
          
          @material_consumption1 = @so_entry1.active_material_consumptions.first 
          @item1.reload 
          @initial_ready1 = @item1.ready
          @so.confirm
          @so_entry1.reload 
          @item1.reload 
          @material_consumption1.reload 
          @service_execution_soe1.reload
        end
        
        it 'should confirm the service execution' do
          @so_entry1.active_service_executions.each do |service_execution|
            service_execution.is_confirmed.should be_true 
          end
        end
        
        it 'should create commission for the service execution' do
          @so_entry1.active_service_executions.each do |service_execution|
            service_execution.commission.should be_valid 
          end
        end
        
        it 'should confirm sales_order and sales_order_entry' do
          @so.is_confirmed.should be_true 
          @so_entry1.is_confirmed.should be_true 
        end
        
        it 'should deduct item ready' do
           @final_ready1 = @item1.ready 
           diff = @initial_ready1 - @final_ready1 
           diff.should == @material_consumption1.usage_option.quantity 
         end
        
        it 'should confirm material consumption' do 
          @so_entry1.active_material_consumptions.each do |material_consumption|
            material_consumption.is_confirmed.should be_true 
          end
        end
        
        
        it 'should produce commission' do
           @so_entry1.reload 
           @commissionable_list = [] 
           @so_entry1.service_executions.each do |service_execution|
             @commissionable_list << {
               :commissionable_type => service_execution.class.to_s ,
               :commissionable_id => service_execution.id 
             }
           end
           @commissionable_list.each do |commissionable_hash|
             Commission.where(
               :commissionable_type => commissionable_hash[:commissionable_type],
               :commissionable_id => commissionable_hash[:commissionable_id]
             ).count.should == 1 
             
             commission = Commission.where(
               :commissionable_type => commissionable_hash[:commissionable_type],
               :commissionable_id => commissionable_hash[:commissionable_id]
             ).first 
             
             commission.commission_amount.should == commission.commissionable.commission_amount 
           end
         end
         
        it 'should produce sub_documents: stock_mutation from material_consumption ' do
           @so_entry1.reload 
           @stock_mutation_list = [] 
           @so_entry1.material_consumptions.each do |material_consumption|
             @stock_mutation_list << {
               :source_document_entry => material_consumption.class.to_s ,
               :source_document_entry_id => material_consumption.id 
             }
           end
           
           @stock_mutation_list.each do |stock_mutation_hash|
             StockMutation.where(
             :source_document_entry => stock_mutation_hash[:source_document_entry],
             :source_document_entry_id => stock_mutation_hash[:source_document_entry_id]
             ).count.should == 1 
           end
         end
         
         
        
        context "update usage option post confirm" do
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
           
          it 'should recover the item1 ready' do
            @final_item1_ready = @item1.ready 
            diff               = @final_item1_ready - @initial_item1_ready 
            diff.should == @mu1_usage_option1.quantity
          end
        end
        
        context "add sales_order_entry post confirm " do
          before(:each) do
            @so_entry2 = SalesOrderEntry.create_object(  @so, {
              :entry_id =>   @service.id ,
              :entry_case =>  SALES_ORDER_ENTRY_CASE[:service] ,
              :quantity =>  10 ,
              :discount => '0',
              :employee_id => @employee.id  
            })

            @so_entry2.reload 
          end

          it 'should auto confirm the sales order entry ' do
            @so_entry2.is_confirmed.should be_true 
          end

          it 'should create stock_mutation corresponding to the sales_order_entry' do
            @so_entry2.material_consumptions.each do |material_consumption|
              StockMutation.where(
              :source_document_entry => material_consumption.class.to_s , 
              :source_document_entry_id => material_consumption.id 
              ).count.should == 1 
            end 
          end

          it 'should  auto create service execution' do
            @so_entry2.service_executions.count.should == @so_entry2.sellable.service_components.count 
          end

          it 'should auto confirm service execution created after so confirmation' do 
            @so_entry2.active_service_executions.each do |service_execution|
              service_execution.is_confirmed.should be_true 
              service_execution.commission.should be_nil 
            end
          end
        end
        
        
        
        
        context "destroy sales_order_enrty" do
          before(:each) do
            @item1.reload
            @so_entry1.reload 
            @initial_item1_ready = @item1.ready 
            @quantity_consumed = @material_consumption1.usage_option.quantity 
            @commissionable_list = [] 
            @so_entry1.service_executions.each do |service_execution|
              @commissionable_list << {
                :commissionable_type => service_execution.class.to_s ,
                :commissionable_id => service_execution.id 
              }
            end

            @stock_mutation_list = [] 
            @so_entry1.material_consumptions.each do |material_consumption|
              @stock_mutation_list << {
                :source_document_entry => material_consumption.class.to_s ,
                :source_document_entry_id => material_consumption.id 
              }
            end
            @so_entry1.delete_object 
            @so_entry1.reload 
            @item1.reload 
          end
          
          it 'should not have any active_service_execution or active_material_consumption' do
            @so_entry1.active_service_executions.count.should == 0 
            @so_entry1.active_material_consumptions.count.should == 0 
          end

          it 'should recover the item1 ready' do
            @final_item1_ready = @item1.ready 
            diff = @final_item1_ready - @initial_item1_ready 
            diff.should == @quantity_consumed
          end

          it 'should not destroy the sales order entry, but mark it as is deleted' do
            @so_entry1.is_deleted.should be_true 
            @so.reload
            @so.active_sales_order_entries.count.should == 0 
          end

          it 'should destroy the commission' do
            @commissionable_list.each do |commissionable_hash|
              Commission.where(
              :commissionable_type => commissionable_hash[:commissionable_type],
              :commissionable_id => commissionable_hash[:commissionable_id]
              ).count.should == 0 
            end
          end

          it 'should destroy the stock mutation from sub_document' do
            @stock_mutation_list.each do |stock_mutation_hash|
              StockMutation.where(
              :source_document_entry => stock_mutation_hash[:source_document_entry],
              :source_document_entry_id => stock_mutation_hash[:source_document_entry_id]
              ).count.should == 0
            end
          end
        end


      end
      
      
       #       
       # context "confirming the sales_order" do
       #   before(:each) do
       #     
       #     # add service execution to the so_entry1 
       #     
       #     @service_execution_soe1 = @so_entry1.service_executions.first 
       #     
       #     @material_consumption1 = @so_entry1.material_consumptions.first 
       #     @item1.reload 
       #     @initial_ready1 = @item1.ready
       #     @so.confirm
       #     @so_entry1.reload 
       #     @item1.reload 
       #     @material_consumption1.reload 
       #     @service_execution_soe1.reload 
       #   end
       #   
       #   it 'should confirm the service_execution' do
       #     @so_entry1.service_executions.each do |service_execution|
       #       service_execution.is_confirmed.should be_true  
       #     end
       #   end
       #   
       #   it 'should not produce commission' do
       #     @so_entry1.service_executions.each do |service_execution|
       #        service_execution.commission.should be_nil  
       #      end
       #   end
       # 
       #   it 'should confirm the sales_order and sales_order_entry' do
       #     @so.is_confirmed.should be_true 
       #     @so_entry1.is_confirmed.should be_true 
       #   end
       #   
       #   it 'should deduct item ready' do
       #     @final_ready1 = @item1.ready 
       #     diff = @initial_ready1 - @final_ready1 
       #     diff.should == @material_consumption1.usage_option.quantity 
       #   end
       #   
       #   it 'should confirm material consumption' do
       #     @material_consumption1.is_confirmed.should be_true 
       #   end
       #   
       #  context "update usage_option post confirm" do
         #   before(:each) do
         #     @item1.reload
         #     @item2.reload 
         #     @initial_item1_ready = @item1.ready
         #     @initial_item2_ready = @item2.ready 
         #     @material_consumption1.update_object({
         #       :usage_option_id => @mu1_usage_option2.id
         #     })
         #     
         #     @item1.reload
         #     @item2.reload
         #   end
         #   
         #   it 'should update the material_consumption1' do
         #     @material_consumption1.errors.size.should ==0 
         #     @material_consumption1.usage_option_id.should == @mu1_usage_option2.id 
         #   end
         #   
         #   it 'should recover item1 ready' do
         #     @final_item1_ready = @item1.ready 
         #     diff = @final_item1_ready - @initial_item1_ready 
         #     diff.should == @mu1_usage_option1.quantity 
         #   end
         #   
         #   it 'should deduct item2 ready' do
         #     @final_item2_ready = @item2.ready
         #     diff = @initial_item2_ready - @final_item2_ready 
         #     diff.should == @mu1_usage_option2.quantity 
         #   end
         # end
         #    
        # context "destroy material_consumption" do
        #   before(:each) do
        #     @item1.reload
        #     @initial_item1_ready = @item1.ready
        #     @material_consumption1.delete_object 
        #     @item1.reload 
        #   end
        #    
        #   it 'should recover the item1 ready' do
        #     @final_item1_ready = @item1.ready 
        #     diff               = @final_item1_ready - @initial_item1_ready 
        #     diff.should == @mu1_usage_option1.quantity
        #   end
        # end
       # 
       #   
       #   
        # it 'should produce commission' do
        #    @so_entry1.reload 
        #    @commissionable_list = [] 
        #    @so_entry1.service_executions.each do |service_execution|
        #      @commissionable_list << {
        #        :commissionable_type => service_execution.class.to_s ,
        #        :commissionable_id => service_execution.id 
        #      }
        #    end
        #    @commissionable_list.each do |commissionable_hash|
        #      Commission.where(
        #        :commissionable_type => commissionable_hash[:commissionable_type],
        #        :commissionable_id => commissionable_hash[:commissionable_id]
        #      ).count.should == 1 
        #      
        #      commission = Commission.where(
        #        :commissionable_type => commissionable_hash[:commissionable_type],
        #        :commissionable_id => commissionable_hash[:commissionable_id]
        #      ).first 
        #      
        #      commission.commission_amount.should == commission.commissionable.commission_amount 
        #    end
        #  end
        #  
        # it 'should produce sub_documents: stock_mutation from material_consumption ' do
        #    @so_entry1.reload 
        #    @stock_mutation_list = [] 
        #    @so_entry1.material_consumptions.each do |material_consumption|
        #      @stock_mutation_list << {
        #        :source_document_entry => material_consumption.class.to_s ,
        #        :source_document_entry_id => material_consumption.id 
        #      }
        #    end
        #    
        #    @stock_mutation_list.each do |stock_mutation_hash|
        #      StockMutation.where(
        #      :source_document_entry => stock_mutation_hash[:source_document_entry],
        #      :source_document_entry_id => stock_mutation_hash[:source_document_entry_id]
        #      ).count.should == 1 
        #    end
        #  end
       #   
        # context "destroy sales_order_enrty" do
        #    before(:each) do
        #      @item1.reload
        #      @so_entry1.reload 
        #      @initial_item1_ready = @item1.ready 
        #      @quantity_consumed = @material_consumption1.usage_option.quantity 
        #      @commissionable_list = [] 
        #      @so_entry1.service_executions.each do |service_execution|
        #        @commissionable_list << {
        #          :commissionable_type => service_execution.class.to_s ,
        #          :commissionable_id => service_execution.id 
        #        }
        #      end
        #      
        #      @stock_mutation_list = [] 
        #      @so_entry1.material_consumptions.each do |material_consumption|
        #        @stock_mutation_list << {
        #          :source_document_entry => material_consumption.class.to_s ,
        #          :source_document_entry_id => material_consumption.id 
        #        }
        #      end
        #      @so_entry1.delete_object 
        #      @item1.reload 
        #    end
        #    
        #    it 'should recover the item1 ready' do
        #      @final_item1_ready = @item1.ready 
        #      diff = @final_item1_ready - @initial_item1_ready 
        #      diff.should == @quantity_consumed
        #    end
        #    
        #    it 'should not destroy the sales order entry, but mark it as is deleted' do
        #      @so_entry1.is_deleted.should be_true 
        #      @so.reload
        #      @so.active_sales_order_entries.count.should == 0 
        #    end
        #    
        #    it 'should destroy the commission' do
        #      @commissionable_list.each do |commissionable_hash|
        #        Commission.where(
        #          :commissionable_type => commissionable_hash[:commissionable_type],
        #          :commissionable_id => commissionable_hash[:commissionable_id]
        #        ).count.should == 0 
        #      end
        #    end
        #    
        #    it 'should destroy the stock mutation from sub_document' do
        #      @stock_mutation_list.each do |stock_mutation_hash|
        #        StockMutation.where(
        #        :source_document_entry => stock_mutation_hash[:source_document_entry],
        #        :source_document_entry_id => stock_mutation_hash[:source_document_entry_id]
        #        ).count.should == 0
        #      end
        #      
        #    end
        #  end
       # 
        # context "add sales_order_entry post confirm " do
        #    before(:each) do
        #      @so_entry2 = SalesOrderEntry.create_object(  @so, {
        #        :entry_id =>   @service.id ,
        #        :entry_case =>  SALES_ORDER_ENTRY_CASE[:service] ,
        #        :quantity =>  10 ,
        #        :discount => '0',
        #        :employee_id => @employee.id  
        #      })
        #      
        #      @so_entry2.reload 
        #    end
        #    
        #    it 'should auto confirm the sales order entry ' do
        #      @so_entry2.is_confirmed.should be_true 
        #    end
        #    
        #    it 'should create stock_mutation corresponding to the sales_order_entry' do
        #      @so_entry2.material_consumptions.each do |material_consumption|
        #        StockMutation.where(
        #          :source_document_entry => material_consumption.class.to_s , 
        #          :source_document_entry_id => material_consumption.id 
        #        ).count.should == 1 
        #      end 
        #    end
        #    
        #    it 'should not auto create service execution' do
        #      @so_entry2.service_executions.count.should == 0  
        #    end
        #    
        #    it 'should auto confirm service execution created after so confirmation' do 
        #      @service_execution_soe2 = ServiceExecution.create_object({
        #        :employee_id => @employee.id ,
        #        :service_component_id => @service_component1.id , 
        #        :sales_order_entry_id => @so_entry2.id 
        #      })
        #      @service_execution_soe2.should be_valid 
        #      @service_execution_soe2.is_confirmed.should be_true 
        #      
        #      @service_execution_soe2.commission.should be_valid 
        #    end
        #  end
       # 
       # end
       #     
    
    
    end
  end

 

end
