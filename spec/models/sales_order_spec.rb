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
    
    @customer = Customer.create_object(:name => "McDonald Teluk Bitung")
    
    # create item  
    @selling_price = "100000"
    @item_name = "Test Item"
    @item1  = Item.create_object(  {
      :name          =>  "#{@item_name} 1" ,
      :selling_price => @selling_price
    })
    @item1.reload 
    
    @item2  = Item.create_object(  {
      :name          =>  "#{@item_name} 2" ,
      :selling_price => @selling_price
    })
    @item2.reload
    
    @item3  = Item.create_object(  {
      :name          =>  "#{@item_name} 3" ,
      :selling_price => @selling_price
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
    
    @stock_migration2 = StockMigration.create_object({
      :item_id => @item2.id, 
      :quantity => @quantity2 , 
      :average_cost => @average_cost_2
    })
    
    @stock_migration3 = StockMigration.create_object({
      :item_id => @item3.id, 
      :quantity => @quantity3 , 
      :average_cost => @average_cost_3
    })
    
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
        :discount => '0'
      })
      so_entry.should be_valid
    end
    
    it 'should be allowed to create so entry with discount between 0-100%' do
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id =>   @item1.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
        :quantity =>  1 ,
        :discount => '100'
      })
      so_entry.should be_valid
      so_entry.delete
      
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id =>   @item1.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
        :quantity =>  1 ,
        :discount => '0'
      })
      so_entry.should be_valid
      so_entry.delete
      
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id =>   @item1.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
        :quantity =>  1 ,
        :discount => '101'
      })
      so_entry.should_not be_valid
      so_entry.delete
      
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id =>   @item1.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
        :quantity =>  1 ,
        :discount => '-5'
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
        :discount => '0'
      })
      so_entry.should be_valid
      
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id => @item1.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
        :quantity => 3  ,
        :discount => '0'
      })
      so_entry.should_not be_valid
    end
    
    it 'should not be allowed to receive 0 or minus' do
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id => @item1.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
        :quantity =>  0  ,
        :discount => '0'
      })
      so_entry.should_not be_valid
      so_entry.delete 
      
      so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id => @item1.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
        :quantity =>  -1 ,
        :discount => '0'
      })
      so_entry.should_not be_valid
      so_entry.delete 
    end
    
    context "so_entry creation" do
      before(:each) do
        @so_quantity1 = 3
        
        @so_entry1 = SalesOrderEntry.create_object(  @so, {
          :entry_id => @item1.id ,
          :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
          :quantity =>  @so_quantity1 ,
          :discount => '0'
        })
        @so_quantity2 = 1
        @so_entry2 = SalesOrderEntry.create_object(  @so, {
          :entry_id => @item2.id ,
          :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
          :quantity =>  @so_quantity2 ,
          :discount => '0'
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
          :discount => '0'
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
          :discount => '0'
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
          
          @so.confirm 
          @item1.reload
          @item2.reload 
          @so_entry1.reload
          @so_entry2.reload
        end
        
        it 'should confirm the so and its entries' do
          @so.is_confirmed.should be_true 
          @so_entry1.is_confirmed.should be_true 
          @so_entry2.is_confirmed.should be_true 
        end
        
        it 'should deduct the item ready quantity' do
        end
        
        it 'should deduct the stock_entry remaining quantity' do
        end
        
        # it 'should update the pending delivery' do
        #   @final_pending_delivery1 = @item1.pending_delivery
        #   @final_pending_delivery2 = @item2.pending_delivery
        #   
        #   diff1 = @final_pending_delivery1 - @initial_pending_delivery1 
        #   diff2 = @final_pending_delivery2 - @initial_pending_delivery2 
        #   diff1.should == @so_quantity1 
        #   diff2.should == @so_quantity2 
        # end
        
        # FIRST BRANCH: update post confirm 
        # it 'should preserve entry uniqueness post confirm' do
        #   @so_entry1.update_object(  {
        #     :item_id => @item2.id,
        #     :quantity => 15
        #   })
        #   @so_entry1.should_not be_valid 
        # end
        
        # it 'should allow item change update' do
        #   @item1.reload
        #   @item3.reload
        #   
        #   initial_so1_quantity = @so_entry1.quantity 
        #   initial_pending_delivery1 = @item1.pending_delivery 
        #   initial_pending_delivery3 = @item3.pending_delivery
        #   @so_entry1.update_object(  {
        #     :item_id => @item3.id,
        #     :quantity => @so_quantity1  
        #   })
        #   @so_entry1.should be_valid 
        #   
        #   
        #   @item1.reload
        #   @item3.reload 
        #   
        #   final_pending_delivery1 = @item1.pending_delivery
        #   final_pending_delivery3 = @item3.pending_delivery
        #   
        #   diff1 = initial_pending_delivery1  - final_pending_delivery1 
        #   diff1.should == initial_so1_quantity
        #   
        #   diff3 = final_pending_delivery3 - initial_pending_delivery3
        #   diff3.should == @so_quantity1
        # end
        
        # it 'should  allow quantity update => change pending delivery' do
        #   @extra_diff = 5 
        #   initial_pending_delivery = @item1.pending_delivery
        #   @so_entry1.update_object(  {
        #     :item_id => @item1.id,
        #     :quantity => @so_quantity1 + @extra_diff 
        #   })
        #   @so_entry1.should be_valid 
        #   
        #   
        #   @item1.reload
        #   final_pending_delivery = @item1.pending_delivery
        #   diff = final_pending_delivery - initial_pending_delivery
        #   diff.should == @extra_diff
        #   
        # end
        
        # SECOND BRANCH: delete post confirm 
        
        # it 'should allow deletion' do
        #   initial_pending_delivery1 = @item1.pending_delivery
        #   quantity = @so_entry1.quantity 
        #   @so_entry1.delete(@admin)
        #   
        #   @item1.reload 
        #   final_pending_delivery1 = @item1.pending_delivery
        #   
        #   diff =  initial_pending_delivery1 - final_pending_delivery1 
        #   diff.should == quantity 
        #   
        #   @so_entry1.persisted?.should be_false 
        # end
        # 
        # context "coupled has takes place (in this case: Delivery)" do
        # end
        
      end
          
    
    
    end
  end
  



end
