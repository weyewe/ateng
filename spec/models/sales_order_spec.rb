require 'spec_helper'

describe SalesOrder do
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
  end
  
  
  it 'should create item ready' do
    @item1.ready.should == @quantity1
    @item2.ready.should == @quantity2
    @item3.ready.should == @quantity3
  end
  
  
  
  it 'should create sales order' do
    @so = SalesOrder.create_object({
      :customer_id => @customer.id 
    } )
    
    @so.should be_valid 
  end
  
  context "post so creation" do
    before(:each) do
      @so = SalesOrder.create_object( {
        :customer_id => @customer.id  
      } )
    end
    
    it 'should be allowed to create so entry' do
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id =>   @item1.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
        :quantity =>  1 ,
        :discount => '0',
        :employee_id => @employee.id  
      })
      so_entry.should be_valid
    end
    
    it 'should be allowed to create so entry with discount between 0-100%' do
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id =>   @item1.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
        :quantity =>  1 ,
        :discount => '100',
        :employee_id => @employee.id  
      })
      so_entry.should be_valid
      so_entry.delete
      
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id =>   @item1.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
        :quantity =>  1 ,
        :discount => '0',
        :employee_id => @employee.id
      })
      so_entry.should be_valid
      so_entry.delete
      
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id =>   @item1.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
        :quantity =>  1 ,
        :discount => '101',
        :employee_id => @employee.id
      })
      so_entry.should_not be_valid
      so_entry.delete
      
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id =>   @item1.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
        :quantity =>  1 ,
        :discount => '-5',
        :employee_id => @employee.id
      })
      so_entry.should_not be_valid
      so_entry.delete
    end
    
    it 'should ensure unique entry' do
      diff = 5 
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id => @item1.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
        :quantity =>  5 ,
        :discount => '0',
        :employee_id => @employee.id
      })
      so_entry.should be_valid
      
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id => @item1.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
        :quantity => 3  ,
        :discount => '0',
        :employee_id => @employee.id
      })
      so_entry.should_not be_valid
    end
    
    it 'should not be allowed to receive 0 or minus' do
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id => @item1.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
        :quantity =>  0  ,
        :discount => '0',
        :employee_id => @employee.id
      })
      so_entry.should_not be_valid
      so_entry.delete 
      
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id => @item1.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
        :quantity =>  -1 ,
        :discount => '0',
        :employee_id => @employee.id
      })
      so_entry.should_not be_valid
      so_entry.delete 
    end
    
    context "so_entry creation" do
      before(:each) do
        @so_quantity1 = @stock_entry1.remaining_quantity - 4 
        
        @so_entry1 = SalesOrderEntry.create_object(  @so, {
          :entry_id => @item1.id ,
          :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
          :quantity =>  @so_quantity1 ,
          :discount => '0',
          :employee_id => @employee.id
        })
        @so_quantity2 =  @stock_entry2.remaining_quantity
        @so_entry2 = SalesOrderEntry.create_object(  @so, {
          :entry_id => @item2.id ,
          :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
          :quantity =>  @so_quantity2 ,
          :discount => '0',
          :employee_id => @employee.id
        })
      end
      
      it 'should create valid so_entry as long as it is unique' do
        @so_entry1.should be_valid 
        @so_entry2.should be_valid 
        
        @so.sales_order_entries.count.should == 2 
      end
      
      it 'should allow update in quantity or item' do
        @so_entry1.update_object(  {
          :entry_id => @item3.id,
          :quantity => @so_quantity1,
          :discount => '0',
          :employee_id => @employee.id
        })
        
        @so_entry1.should be_valid 
        @so_entry1.reload 
        @so_entry1.entry_id.should == @item3.id 
        @so_entry1.quantity.should == @so_quantity1
      end
      
      it 'should still preserve the unique entry on update' do
        @so_entry1.update_object(  {
          :entry_id => @item2.id,
          :quantity => @so_quantity1,
          :discount => '0',
          :employee_id => @employee.id
        })
        @so_entry1.should_not be_valid 
      end
      
      
      
      
      
      context "confirm sales order" do
        before(:each) do
          @so.reload
          @item1.reload
          @item2.reload 
          @so_entry1.reload
          @so_entry2.reload
          # @initial_pending_delivery1 = @item1.pending_delivery
          # @initial_pending_delivery2 = @item2.pending_delivery
          @initial_ready = @item1.ready 
          @stock_entry1.reload
          @stock_entry2.reload 
          @initial_remaining_quantity1 = @stock_entry1.remaining_quantity 
          @initial_remaining_quantity2 = @stock_entry2.remaining_quantity 
          
          @so.confirm 
          @item1.reload
          @item2.reload 
          @so_entry1.reload
          @so_entry2.reload
          @stock_entry1.reload 
          @stock_entry2.reload 
        end
        
        it 'should confirm the so and its entries' do
          @so.is_confirmed.should be_true 
          @so_entry1.is_confirmed.should be_true 
          @so_entry2.is_confirmed.should be_true 
        end
        
        it 'should deduct the item ready quantity' do
          @final_ready = @item1.ready 
          diff = @initial_ready - @final_ready 
          diff.should == @so_quantity1 
        end
        
        it 'should deduct the stock_entry remaining quantity' do
          # in this case, for the so_entry1, we designed that the 
          # => sales quantity is less than the remaining_quantity in stock migration
          @final_remaining_quantity1 = @stock_entry1.remaining_quantity
          @diff = @initial_remaining_quantity1 - @final_remaining_quantity1 
          @diff.should == @so_quantity1  
        end
        
        it 'should deduct the stock_entry remaining quantity. If it is finished, is_finished is set to be true' do
          # in this case, for the so_entry2, we designed that the
          # => sales_quantity is equal to the remaining quantity in stock_migration
          @final_remaining_quantity2 = @stock_entry2.remaining_quantity
          @diff = @initial_remaining_quantity2 - @final_remaining_quantity2
          @diff.should == @so_quantity2
          @stock_entry2.is_finished.should be_true 
          @stock_entry2.remaining_quantity.should == 0 
        end
        
        
        
        
        it 'should still preserve uniqueness' do
          @so_entry1.update_object({
            :entry_id => @item2.id,
            :quantity => 1,
            :discount => '0',
            :employee_id => @employee.id
          })
          @so_entry1.errors.size.should_not == 0 
        end
        
        
        # POST CONFIRM UPDATE: update quantity 
        it 'should  allow quantity update if it does not exceed  the available item' do
          @so_entry1.update_object({
            :entry_id => @item1.id,
            :quantity => @quantity1,
            :discount => '0',
            :employee_id => @employee.id
          })
          
          @so_entry1.errors.size.should == 0 
        end
        
        it 'should not ALLOW quantity update if it exceeds the available item' do
          @so_entry1.update_object({
            :entry_id => @item1.id,
            :quantity => @quantity1 + 1 ,
            :discount => '0',
            :employee_id => @employee.id
          })
          
          @so_entry1.errors.size.should_not == 0
          @so_entry1.should_not be_valid 
        end
        
        # POST CONFIRM UPDATE: update item => from 1 to 3 
        
        context "post_confirm: update item" do
          before(:each) do
            # puts "GONNA START UPDATE ITEM\n"*10
            @stock_entry1.reload
            @stock_entry3.reload 
            @item1.reload
            @item3.reload 
            @initial_item_ready1 = @item1.ready 
            @initial_item_ready3 = @item3.ready 
            @initial_remaining_quantity1 = @stock_entry1.remaining_quantity
            @initial_remaining_quantity3 = @stock_entry3.remaining_quantity
            @quantity_used_from_item1 = @so_entry1.quantity 
            
            @quantity_to_be_used_from_item3 =  @quantity3 - 1 
            @so_entry1.update_object({
              :entry_id => @item3.id,
              :quantity => @quantity_to_be_used_from_item3,
              :discount => '0',
              :employee_id => @employee.id
            })
            
            @stock_entry1.reload
            @stock_entry3.reload 
            @item1.reload
            @item3.reload
          end
          
          it 'should be valid' do
            @so_entry1.should be_valid 
          end
          
          it 'should recover the item1.ready' do
            @final_item_ready1 = @item1.ready 
            diff = @final_item_ready1 - @initial_item_ready1
            diff.should == @quantity_used_from_item1
          end
          
          it 'should recover the item1.ready: prove that there is no item.update_ready_quantity [version2: manual update]' do
            @stock_entry1.update_remaining_quantity 
            @item1.update_ready_quantity 
            @final_item_ready1 = @item1.ready 
            diff = @final_item_ready1 - @initial_item_ready1
            diff.should == @quantity_used_from_item1
          end
          # shit, not updated 
          
          it 'should recover the stock_entry1.remaining_quantity' do
            @final_remaining_quantity1  = @stock_entry1.remaining_quantity 
            diff = @final_remaining_quantity1 - @initial_remaining_quantity1 
            diff.should == @quantity_used_from_item1
          end
          
          
          # FUUUCK... so, in the update_object, no update_remaining_quantity and no item.update_ready_quantity
          it 'should recover the stock_entry1.remaining_quantity [version2.. manual update_remaining_quantity]' do
            @stock_entry1.update_remaining_quantity 
            @final_remaining_quantity1  = @stock_entry1.remaining_quantity 
            diff = @final_remaining_quantity1 - @initial_remaining_quantity1 
            diff.should == @quantity_used_from_item1
          end
          
          it 'should reduce the item3.ready' do
            @final_item_ready3 = @item3.ready 
            diff = @initial_item_ready3  - @final_item_ready3
            diff.should == @quantity_to_be_used_from_item3
          end
          
          it 'should reduce the stock_entry3.remaining_quantity' do
            @final_remaining_quantity3  = @stock_entry3.remaining_quantity 
            diff = @initial_remaining_quantity3  - @final_remaining_quantity3
            diff.should == @quantity_to_be_used_from_item3
          end
        end 

        
        
        
        
        context "post_confirm: delete" do
          before(:each) do
            @stock_entry1.reload
            @stock_entry3.reload 
            @item1.reload
            @item3.reload 
            @initial_item_ready1 = @item1.ready 
            @initial_item_ready3 = @item3.ready 
            @initial_remaining_quantity1 = @stock_entry1.remaining_quantity
            @initial_remaining_quantity3 = @stock_entry3.remaining_quantity
            @quantity_used_from_item1 = @so_entry1.quantity 
            
            @so_entry1.delete_object
            
            @stock_entry1.reload
            @stock_entry3.reload 
            @item1.reload
            @item3.reload
          end
          
          it 'should mark the so_entry1 as deleted' do
            @so_entry1.is_deleted.should be_true
          end
          
          it 'should   increase the remaining_quantity in stock_entry1' do
            @final_remaining_quantity1 = @stock_entry1.remaining_quantity 
            diff = @final_remaining_quantity1- @initial_remaining_quantity1
            diff.should == @quantity_used_from_item1
          end
          
          it 'should increase the item ready in item1' do
            @final_item_ready1 = @item1.ready 
            diff = @final_item_ready1 - @initial_item_ready1
            diff.should == @quantity_used_from_item1
          end 
        end

      end
    end
  end
  



end
