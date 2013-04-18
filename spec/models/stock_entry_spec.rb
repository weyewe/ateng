require 'spec_helper'

# Scenario: create stock migration (1 stock_entry)
# create purchase receival ( 1 stock_entry ) 

# create usage that spans stock_entry1 and stock_entry2 
# contract the stock_entry1 => see if it shifted => 
## Vary the contraction amount => spill to stock_entry 3 ?

describe StockEntry do
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
    @stock_entry_1 = @stock_migration1.stock_entry 
    
   
    
    @item1.reload
    
    @po = PurchaseOrder.create_object(  {
      :supplier_id => @supplier.id 
    })
    
    @po_quantity1 = 20
    @po_entry1 = PurchaseOrderEntry.create_object(  @po, {
      :item_id => @item1.id ,
      :quantity => @po_quantity1 
    })
    
    
    @po.confirm 
    @po_entry1.reload 
    @receival_quantity1 = 10
    @receival_quantity2 = 8
    
    
    @item1.reload
    @pr = PurchaseReceival.create_object({
      :supplier_id =>  @supplier.id  
    })
    @pr_entry_1 = PurchaseReceivalEntry.create_object(  @pr, {
      :purchase_order_entry_id => @po_entry1.id ,
      :quantity => @receival_quantity1 
    })
    @pr.confirm 
    
    @stock_entry_2 = StockEntry.where(
      :source_document_entry => @pr_entry_1.class.to_s,
      :source_document_entry_id => @pr_entry_1.id 
    ).first
    
    @item1.reload
    @pr = PurchaseReceival.create_object({
      :supplier_id =>  @supplier.id  
    })
    @pr_entry_2 = PurchaseReceivalEntry.create_object(  @pr, {
      :purchase_order_entry_id => @po_entry1.id ,
      :quantity => @receival_quantity2
    })
    
    @pr.confirm
    @stock_entry_3 = StockEntry.where(
      :source_document_entry => @pr_entry_2.class.to_s,
      :source_document_entry_id => @pr_entry_2.id 
    ).first
    @item1.reload
  end
  
  it 'should produce 3 stock_entries' do
    @item1.stock_entries.count.should == 3 
  end
  
  it 'should update item_ready' do
    @item1.ready.should == @quantity1 + @receival_quantity1 + @receival_quantity2
  end
  
  
  # context: sales order, quantity doesn't span multiple stock entries
  # but, during contraction, it will span multiple stock entries
  context "initial usage doesn't span multiple stock_entries" do
    before(:each) do
      @stock_entry_1.reload
      @stock_entry_2.reload
      @stock_entry_3.reload
      @so = SalesOrder.create_object( {
        :customer_id => @customer.id  
      } )
      
      @diff_quantity1 = 3 
      @sales_quantity = @quantity1 - @diff_quantity1
      
      @so_entry = SalesOrderEntry.create_object(  @so, {
        :entry_id =>   @item1.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
        :quantity =>  @sales_quantity ,
        :discount => '0',
        :employee_id => @employee.id
      })
      
      @so.confirm 
      @stock_entry_1.reload
      @stock_entry_2.reload
      @stock_entry_3.reload
    end
    
    it 'should reduce the remaining_quantity of stock_entry_1' do
      @stock_entry_1.remaining_quantity.should == @diff_quantity1
    end
    
    context 'contracting the first stock_entry so that the excess will be spilled to the next available stock_entry' do
      before(:each) do
        @spilled_quantity = 2 
        @item1.reload
        @initial_ready1 = @item1.ready 
        @new_quantity = @quantity1 - @spilled_quantity - @diff_quantity1
        @stock_migration1.update_object(  {
          :quantity => @new_quantity,
          :average_cost => @stock_migration1.average_cost  
          } )
          
        @stock_entry_1.reload 
        @stock_entry_2.reload 
        @item1.reload 
      end
      
      it 'should deduct item ready quantity' do
        @final_ready1 = @item1.ready
        diff=  @initial_ready1 - @final_ready1 
        diff.should == @spilled_quantity + @diff_quantity1
      end
      
      it 'should mark the stock_entry_1 as finished' do
        @stock_entry_1.is_finished.should be_true 
        @stock_entry_1.remaining_quantity.should == 0 
      end
      
      it 'should deduct the remaining quantity of stock_entry_2 equal to @spilled_quantity' do
        @stock_entry_2.remaining_quantity.should == @stock_entry_2.quantity - @spilled_quantity 
      end
      
    end
  end
  
 
end
