require 'spec_helper'

describe PurchaseOrder do
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
  end
  
  it 'should create purchase order' do
    po = PurchaseOrder.create_object( {
      :supplier_id => @supplier.id 
    })
    
    po.should be_valid 
  end
  
  context 'post po creation' do
    before(:each) do
      @po = PurchaseOrder.create_object(  {
        :supplier_id => @supplier.id 
      })
    end
    
    it 'should be allowed to create po_entry' do
      po_entry = PurchaseOrderEntry.create_object(@po, {
        :item_id => @item1.id ,
        :quantity => 15 
      })
      po_entry.should be_valid 
    end
    
    it 'should ensure unique entry' do
      po_entry = PurchaseOrderEntry.create_object(  @po, {
        :item_id => @item1.id ,
        :quantity => 15 
      })
      po_entry.should be_valid
      
      po_entry = PurchaseOrderEntry.create_object(  @po, {
        :item_id => @item1.id ,
        :quantity => 20 
      })
      po_entry.should_not be_valid
    end
    
    it 'should not allow quantity less or equal to 0' do
      po_entry = PurchaseOrderEntry.create_object(  @po, {
        :item_id => @item1.id ,
        :quantity => -5 
      })
      po_entry.should_not be_valid
      
      po_entry = PurchaseOrderEntry.create_object( @po, {
        :item_id => @item1.id ,
        :quantity => 0 
      })
      po_entry.should_not be_valid
    end
    
    context 'po_entry creation' do
      before(:each) do
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
      end
      
      it 'should create valid po_entry as long as it is unique' do
        @po_entry1.should be_valid 
        @po_entry2.should be_valid 
        
        @po.purchase_order_entries.count.should == 2 
      end
      
      it 'should allow update in quantity or item' do
        @po_entry1.update_object( {
          :item_id => @item3.id,
          :quantity => @po_quantity1
        })
        
        @po_entry1.should be_valid 
        @po_entry1.reload 
        @po_entry1.item_id.should == @item3.id 
        @po_entry1.quantity.should == @po_quantity1
      end
      
      it 'should still preserve the unique entry on update' do
        @po_entry1.update_object(  {
          :item_id => @item2.id,
          :quantity => @po_quantity1
        })
        @po_entry1.should_not be_valid 
      end
      
      context "confirm purchase order" do
        before(:each) do
          @po.reload
          @item1.reload
          @item2.reload 
          @po_entry1.reload
          @po_entry2.reload
          @initial_pending_receival1 = @item1.pending_receival
          @initial_pending_receival2 = @item2.pending_receival
          
          @po.confirm 
          @item1.reload
          @item2.reload 
          @po_entry1.reload
          @po_entry2.reload 
        end
        
        it 'should confirm the po and its entries' do
          @po.is_confirmed.should be_true 
          @po_entry1.is_confirmed.should be_true 
          @po_entry2.is_confirmed.should be_true 
        end
        
        it 'should update the pending receival' do
          @final_pending_receival1 = @item1.pending_receival
          @final_pending_receival2 = @item2.pending_receival 
          
          diff1 = @final_pending_receival1 - @initial_pending_receival1 
          diff2 = @final_pending_receival2 - @initial_pending_receival2 
          diff1.should == @po_quantity1 
          diff2.should == @po_quantity2 
        end
        
        
        # FIRST BRANCH: update post confirm 
        it 'should preserve entry uniqueness post confirm' do
          @po_entry1.update_object( {
            :item_id => @item2.id,
            :quantity => 15
          })
          @po_entry1.should_not be_valid 
        end
        
        it 'should allow item change update' do
          @item1.reload
          @item3.reload
          
          initial_po1_quantity = @po_entry1.quantity 
          initial_pending_receival1 = @item1.pending_receival 
          initial_pending_receival3 = @item3.pending_receival
          @po_entry1.update_object( {
            :item_id => @item3.id,
            :quantity => @po_quantity1  
          })
          @po_entry1.should be_valid 
          
          
          @item1.reload
          @item3.reload 
          
          final_pending_receival1 = @item1.pending_receival
          final_pending_receival3 = @item3.pending_receival
          
          diff1 = initial_pending_receival1  - final_pending_receival1 
          diff1.should == initial_po1_quantity
          
          diff3 = final_pending_receival3 - initial_pending_receival3
          diff3.should == @po_quantity1
        end
        
      
        
        it 'should  allow quantity update => change pending receival' do
          @extra_diff = 5 
          initial_pending_receival = @item1.pending_receival 
          @po_entry1.update_object( {
            :item_id => @item1.id,
            :quantity => @po_quantity1 + @extra_diff 
          })
          @po_entry1.should be_valid 
          
          
          @item1.reload
          final_pending_receival = @item1.pending_receival
          diff = final_pending_receival - initial_pending_receival
          diff.should == @extra_diff
          
        end
        
        
        
        # SECOND BRANCH: delete post confirm 
        
        it 'should allow deletion' do
          initial_pending_receival1 = @item1.pending_receival
          quantity = @po_entry1.quantity 
          @po_entry1.delete 
          
          @item1.reload 
          final_pending_receival1 = @item1.pending_receival
          
          diff =  initial_pending_receival1 - final_pending_receival1 
          diff.should == quantity 
          
          @po_entry1.persisted?.should be_false 
        end
        
        
        # PURCHASE RECEIVAL 
        
        context "coupled has takes place (in this case: purchase receival)" do
          before(:each) do
            @pr = PurchaseReceival.create_object( {
              :supplier_id => @supplier.id 
            } )
            
            @pr_quantity1 = @po_quantity1 - 5 
            @pr_entry1 = PurchaseReceivalEntry.create_object(  @pr, {
              :purchase_order_entry_id => @po_entry1.id ,
              :quantity => @pr_quantity1 
            })
        
            @pr_quantity2 = @po_quantity2 - 5
            @pr_entry2 = PurchaseReceivalEntry.create_object(  @pr, {
              :purchase_order_entry_id => @po_entry2.id ,
              :quantity => @pr_quantity2 
            })
            @pr.reload
            @pr.confirm 
            @item1.reload
            @item1.reload 
            @pr_entry1.reload
            @pr_entry2.reload 
          end
          
          it 'should provide sane purchase_receival' do
            @pr.is_confirmed.should be_true 
            @pr.active_purchase_receival_entries.count.should == 2 
          end
          
          # FIRST Branch : on update  # can't change the item anymore if there is purchase receival
          it 'should not allow item update' do
            @po_entry1.update_object(  {
              :item_id => @item3.id ,
              :quantity => @po_quantity1
            })
            
            # @po_entry1.should_not be_valid 
            @po_entry1.errors.size.should_not == 0 
          end
          
          it 'should allow quantity update' do
            @po_entry1.update_object(  {
              :item_id => @item1.id ,
              :quantity => @po_quantity1 - 1 
            })
            
            @po_entry1.should be_valid 
          end
          
          it 'should not allow quantity update to be lower than the used quantity' do
            @po_entry1.update_object( {
              :item_id => @item1.id ,
              :quantity => @pr_quantity2 - 1 
            })
            
            @po_entry1.errors.size.should_not == 0 
          end
          
          
          
         
         # Second Branch : on delete  # can't delete the purchase order entry if there is purchase receival
          it 'should not allow delete' do
            @po_entry1.delete 
            @po_entry1.reload
            @po_entry1.persisted?.should be_true 
          end
          
          
        end 
        
        
        
      end
    end
    
  end
end
