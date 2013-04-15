require 'spec_helper'

describe PurchaseReceival do
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
    
    @item1.reload
    @item2.reload
    @item3.reload
    
    @po = PurchaseOrder.create_object(  {
      :supplier_id => @supplier.id 
    })
    
    @po_quantity1 = 15
    @po_entry1 = PurchaseOrderEntry.create_object(  @po, {
      :item_id => @item1.id ,
      :quantity => @po_quantity1 
    })
    
    @po_quantity2 = 30
    @po_entry2 = PurchaseOrderEntry.create_object(  @po, {
      :item_id => @item2.id ,
      :quantity => @po_quantity2 
    })
    
    @po_quantity3 = 10
    @po_entry3 = PurchaseOrderEntry.create_object(  @po, {
      :item_id => @item3.id ,
      :quantity => @po_quantity3 
    })
    
    @po.confirm 
    @po_entry1.reload 
    @po_entry2.reload 
    @po_entry3.reload 
    @item1.reload
    @item2.reload 
    @item3.reload 
  end
  
  # it 'should provide sane purchase order + entries' do
  #   @po.is_confirmed.should be_true 
  #   @po_entry1.is_confirmed.should be_true
  #   @po_entry2.is_confirmed.should be_true 
  #   
  #   @item1.pending_receival.should == @po_quantity1 
  #   @item2.pending_receival.should == @po_quantity2 
  # end
  # 
  # it 'should not allow receival if there is no supplier' do
  #   @pr = PurchaseReceival.create_object({
  #     :supplier_id =>  nil 
  #   })
  #   
  #   @pr.should_not be_valid 
  # end
  # 
  # it 'should allow receival if there is supplier' do
  #   @pr = PurchaseReceival.create_object({
  #     :supplier_id =>  @supplier.id  
  #   })
  #   
  #   @pr.should be_valid
  # end
  
  context "purchase receival creation" do
    before(:each) do
      @pr = PurchaseReceival.create_object({
        :supplier_id =>  @supplier.id  
      })
      

    end
    
    # it 'should  allow receival if quantity received <= remaining quantity ordered' do
    #   @pr_quantity1 = @po_quantity1 - 5 
    #   @pr_entry1 = PurchaseReceivalEntry.create_object(  @pr, {
    #     :purchase_order_entry_id => @po_entry1.id ,
    #     :quantity => @pr_quantity1 
    #   })
    #   @pr_entry1.should be_valid 
    # end
    # 
    # it 'should not allow receival if quantity_received > remaining quantity_ordered' do
    #   @pr_quantity1 = @po_quantity1 + 1  
    #   @pr_entry1 = PurchaseReceivalEntry.create_object(  @pr, {
    #     :purchase_order_entry_id => @po_entry1.id ,
    #     :quantity => @pr_quantity1 
    #   })
    #   @pr_entry1.should_not be_valid
    # end
    
    context "confirming the purchase receival" do
      before(:each) do
        @remaining_pending_receival1 = 5 
        @pr_quantity1 = @po_quantity1 - @remaining_pending_receival1
        @pr_entry1 = PurchaseReceivalEntry.create_object(  @pr, {
          :purchase_order_entry_id => @po_entry1.id ,
          :quantity => @pr_quantity1 
        })
        
        @remaining_pending_receival2 = 5 
        @pr_quantity2 = @po_quantity2 - @remaining_pending_receival2
        @pr_entry2 = PurchaseReceivalEntry.create_object(  @pr, {
          :purchase_order_entry_id => @po_entry2.id ,
          :quantity => @pr_quantity2
        })
   
        @pr.reload
        
        @item1.reload
        @item2.reload 
        @initial_ready1 = @item1.ready 
        @initial_ready2 = @item2.ready 
        @initial_pending_receival1 = @item1.pending_receival 
        @initial_pending_receival2 = @item2.pending_receival 
        
        @pr.confirm 
        @item1.reload
        @item1.reload 
        @pr_entry1.reload
        # @pr_entry2.reload
      end
      
      # it 'should produce 2 pr_entries ' do
      #   @pr.active_purchase_receival_entries.count.should == 2 
      # end
      # 
      # it 'should have confirmed the pr, pr_entry1 and 2 ' do
      #   @pr.is_confirmed.should be_true
      #   @pr_entry1.is_confirmed.should be_true
      # end
      # 
      # it 'should increase the item ready quantity' do
      #   @final_ready1 = @item1.ready
      #   
      #   diff1 = @final_ready1 - @initial_ready1 
      #   diff1.should == @pr_quantity1
      # end
      # 
      # it 'should decrease the item pending receival [RECOVER: manual work]' do      
      #   @final_pending_receival1 = @item1.pending_receival 
      #   diff1 = @initial_pending_receival1 - @final_pending_receival1 
      #   diff1.should == @pr_quantity1
      # end
      # 
      # it 'should produce 2 stock_entries' do
      #   @item1.stock_entries.count.should == 2  # 1 stock_migration and 1 for purchase_receival
      # end
      # 
      # it 'should produce 1 stock_mutation, 1 stock_entry' do
      #   stock_entry =  StockEntry.where(
      #     :source_document_entry => @pr_entry1.class.to_s , 
      #     :source_document_entry_id => @pr_entry1.id
      #   ).first 
      #   
      #   stock_entry.should be_valid 
      #   stock_entry.remaining_quantity.should == @pr_quantity1
      #   
      #   stock_mutation = StockMutation.where(
      #     :source_document_entry => @pr_entry1.class.to_s , 
      #     :source_document_entry_id => @pr_entry1.id,
      #     :mutation_status => MUTATION_STATUS[:addition],
      #     :mutation_case => MUTATION_CASE[:purchase_receival]
      #   ).first
      #   
      #   stock_mutation.should be_valid 
      #   stock_mutation.quantity.should == @pr_quantity1
      #   stock_mutation.item_id.should == @pr_entry1.item_id 
      # end
      # 
      # it 'should still preserve uniqueness' do
      #   @pr_entry1.update_object({
      #     :purchase_order_entry_id => @po_entry2.id ,
      #     :quantity => 1
      #   })
      #   @pr_entry1.errors.size.should_not == 0 
      # end
      # 
      # 
      # # update purchase receival
      # # POST CONFIRM UPDATE: update quantity 
      # it 'should  allow quantity update if it does not exceed  the available item' do
      #   @pr_entry1.update_object({
      #     :purchase_order_entry_id => @po_entry1.id ,
      #     :quantity => @po_quantity1  - 1 
      #   })
      #   
      #   @pr_entry1.errors.size.should == 0 
      # end
      # 
      # it 'should not ALLOW quantity update if it exceeds the available item' do
      #   # puts "======================\n"*10
      #   
      #   @pr_entry1.update_object({
      #     :purchase_order_entry_id => @po_entry1.id ,
      #     :quantity => @po_quantity1  + 1
      #   })
      #   
      #   @pr_entry1.errors.size.should_not == 0
      #   @pr_entry1.should_not be_valid 
      # end
      
        #     
        # 
        # context "update post confirm: quantity contraction" do
        #   before(:each) do
        #     @item1.reload
        #     @pr_entry1.reload 
        # 
        #     @diff = 2 
        #     @new_quantity = @pr_entry1.quantity - @diff 
        #     
        #     @initial_item_ready1 = @item1.ready 
        #     @pr_entry1.update_object({
        #       :purchase_order_entry_id => @po_entry1.id ,
        #       :quantity => @new_quantity   
        #     })
        #      
        #     @item1.reload
        #     @pr_entry1.reload
        #   end
        # 
        #   it 'should be valid update' do
        #     @pr_entry1.errors.size.should == 0 
        #   end
        # 
        #   it 'should change the quantity in stock_entry, stock_mutation, stock_entry_mutation' do
        #     stock_entry = StockEntry.where(
        #     :source_document_entry_id => @pr_entry1.id, 
        #     :source_document_entry => @pr_entry1.class.to_s
        #     ).first 
        #     stock_entry.quantity.should == @new_quantity 
        #     stock_entry.remaining_quantity.should == @new_quantity 
        # 
        #     stock_mutation = StockMutation.where(
        #     :source_document_entry => @pr_entry1.class.to_s, 
        #     :source_document_entry_id => @pr_entry1.id 
        #     ).first 
        #     stock_mutation.quantity.should == @new_quantity 
        # 
        #     stock_entry_mutation = StockEntryMutation.where(
        #     :stock_entry_id    => stock_entry.id , 
        #     :stock_mutation_id => stock_mutation.id  
        #     ).first
        #     stock_entry_mutation.quantity.should == @new_quantity 
        #   end
        # 
        #   it 'should change the item_ready quantity' do
        #     @final_item_ready1 = @item1.ready 
        #     diff = @initial_item_ready1 - @final_item_ready1 
        #     diff.should == @diff 
        #   end
        #   
        #   it 'should change the inventory_value'
        # end
        # 
  
      
       #      
       # context "update post confirm: quantity expansion" do
       #   before(:each) do
       #     @item1.reload
       #     @pr_entry1.reload 
       # 
       #    
       #     @new_quantity =  @pr_entry1.quantity + @remaining_pending_receival1
       #     @initial_item_ready1 = @item1.ready 
       #     @pr_entry1.update_object({
       #       :purchase_order_entry_id => @po_entry1.id ,
       #       :quantity => @new_quantity   
       #     })
       #      
       #     @item1.reload
       #     @pr_entry1.reload 
       #   end
       # 
       #   it 'should be valid update' do
       #     @pr_entry1.errors.size.should == 0 
       #   end
       # 
       #   it 'should change the quantity in stock_entry, stock_mutation, stock_entry_mutation' do
       #     stock_entry = StockEntry.where(
       #     :source_document_entry_id => @pr_entry1.id, 
       #     :source_document_entry => @pr_entry1.class.to_s
       #     ).first 
       #     stock_entry.quantity.should == @new_quantity 
       #     stock_entry.remaining_quantity.should == @new_quantity 
       # 
       #     stock_mutation = StockMutation.where(
       #     :source_document_entry => @pr_entry1.class.to_s, 
       #     :source_document_entry_id => @pr_entry1.id 
       #     ).first 
       #     stock_mutation.quantity.should == @new_quantity 
       # 
       #     stock_entry_mutation = StockEntryMutation.where(
       #     :stock_entry_id    => stock_entry.id , 
       #     :stock_mutation_id => stock_mutation.id  
       #     ).first
       #     stock_entry_mutation.quantity.should == @new_quantity 
       #   end
       # 
       # 
       #   it 'should change the item_ready quantity' do
       #     @final_item_ready1 = @item1.ready
       #     diff = @final_item_ready1 - @initial_item_ready1 
       #     diff.should == @remaining_pending_receival1
       #   end
       #   
       #   it 'should change the inventory_value'
       # end
       # 
 
     
      context "post_confirm: update item" do
        before(:each) do
          @item1.reload
          @item3.reload 
          @initial_item_ready1 = @item1.ready 
          @initial_item_ready3 = @item3.ready 
          @initial_received_quantity = @pr_entry1.quantity 
          @pr_entry1.update_object({
            :purchase_order_entry_id => @po_entry3.id ,
            :quantity => @po_quantity3   
          })

          
          @item1.reload
          @item3.reload
        end

        it 'should be valid' do
          @pr_entry1.errors.size.should == 0 
          @pr_entry1.should be_valid
        end
        
        it 'should refresh stock_entry1' do
          stock_entry = StockEntry.where(
            :source_document_entry => @pr_entry1.class.to_s,
            :source_document_entry_id => @pr_entry1.id 
          ).first 
          stock_entry.should be_valid 
          stock_entry.quantity.should == @po_quantity3
          stock_entry.item_id.should == @item3.id 
          
          stock_mutation = StockMutation.where(
            :source_document_entry => @pr_entry1.class.to_s,
            :source_document_entry_id => @pr_entry1.id 
          ).first 
          
          stock_mutation.should be_valid
          stock_mutation.quantity.should == @po_quantity3 
          stock_mutation.item_id.should == @item3.id 
          
          stock_entry_mutations = StockEntryMutation.where(
            :stock_entry_id => stock_entry.id ,
            :stock_mutation_id => stock_mutation.id ,
            :mutation_case => MUTATION_CASE[:purchase_receival],
            :mutation_status => MUTATION_STATUS[:addition]
          )
          stock_entry_mutations.length.should == 1
          stock_entry_mutations.first.quantity.should == @po_quantity3
        end
        
        it 'should deduct item1.ready' do
          @final_item_ready1 = @item1.ready 
          diff = @initial_item_ready1 - @final_item_ready1
          diff.should == @initial_received_quantity
        end
        
        it 'should increase item3.ready' do
          @final_item_ready3 = @item3.ready 
          diff = @final_item_ready3 - @initial_item_ready3
          diff.should == @po_quantity3
        end
      end 


      
      context "delete purchase receival" do
        before(:each) do
        end
      end
      # on delete purchase receival 
      
    end
  end
  
  
end
