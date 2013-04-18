require 'spec_helper'

describe Commission do
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
    @commission_1 = "10000"
    @item1  = Item.create_object(  {
      :name          =>  "#{@item_name} 1" ,
      :selling_price => @selling_price,
      :commission_amount => @commission_1
    })
    @item1.reload 
    
    @commission_2 = "20000"
    @item2  = Item.create_object(  {
      :name          =>  "#{@item_name} 2" ,
      :selling_price => @selling_price,
      :commission_amount => @commission_2
    })
    @item2.reload
    
    @commission_3 = "30000"
    @item3  = Item.create_object(  {
      :name          =>  "#{@item_name} 3" ,
      :selling_price => @selling_price,
      :commission_amount => @commission_3
    })
    @item3.reload
    
    @quantity1 = 10
    @quantity2 = 10
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
    
    
    @so_quantity1 = @stock_entry1.remaining_quantity - 4 
    
    @so = SalesOrder.create_object( {
      :customer_id => @customer.id  
    } )
    
    
    @so_entry1 = SalesOrderEntry.create_object(  @so, {
      :entry_id => @item1.id ,
      :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
      :quantity =>  @so_quantity1 ,
      :discount => '0',
      :employee_id => @employee.id  
    })
    
    @so.confirm
    @so_entry1.reload 
    
    @commission = @so_entry1.commission
  end
  
  it 'should set sellable' do
    @so_entry1.sellable.class.to_s.should == @item1.class.to_s 
  end
  
  it 'should create commission' do
    @commission.should be_valid 
  end
  
  it 'should assign the appropriate employee_id to the commission' do
    @commission.employee_id.should == @employee.id
  end
  
  it 'should assign the appropriate commission_amount' do
    @commission.commission_amount.should == @item1.commission_amount 
  end
  
  context "update item confirmed sales order entry => update related commission" do
    before(:each) do
      @so_entry1.update_object({
        :entry_id => @item2.id ,
        :entry_case =>  SALES_ORDER_ENTRY_CASE[:item] ,
        :quantity =>  @so_quantity1 ,
        :discount => '0',
        :employee_id => @employee.id
      })
      
      @commission = @so_entry1.commission
    end
    
    it 'should update the commission_amount' do
      @commission.commission_amount.should == @item2.commission_amount 
    end
  end
  
  context "delete commissionable (sales_order_entry)" do
    before(:each) do
      
      @initial_count = Commission.where(
        :commissionable_id => @so_entry1.id ,
        :commissionable_type => @so_entry1.class.to_s
      ).count
      @commission = @so_entry1.commission
      @so_entry1.delete_object
      
    end
    
    it 'should destroy the commission' do
      final_count = Commission.where(
        :commissionable_id => @so_entry1.id ,
        :commissionable_type => @so_entry1.class.to_s
      ).count
      
      final_count.should ==0  
      
      @initial_count.should == 1 
    end
  end
  
  
end
