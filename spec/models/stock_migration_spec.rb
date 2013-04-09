require 'spec_helper'

describe StockMigration do
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
    
    
    # create item  
    @selling_price = "100000"
    @item_name = "Test Item"
    @item  = Item.create_object(  {
      :name          =>  @item_name ,
      :selling_price => @selling_price
    })
    @item.reload 
  end
  
  # PRECONDITION 
  it 'should not allow quantity to be less than zero' do
    stock_migration = StockMigration.create_object({
      :item_id => @item.id, 
      :quantity => 0 , 
      :average_cost => "150000"
    })
    
    stock_migration.should_not be_valid 
    
    stock_migration = StockMigration.create_object({
      :item_id => @item.id, 
      :quantity => -1 , 
      :average_cost => "150000"
    })
    
    stock_migration.should_not be_valid
  end
  
  
  it 'should not allow price to be less than zero' do
    stock_migration = StockMigration.create_object({
      :item_id => @item.id, 
      :quantity => 5 , 
      :average_cost => "-150000"
    })
    
    stock_migration.should_not be_valid
    
     stock_migration = StockMigration.create_object({
        :item_id => @item.id, 
        :quantity => 5 , 
        :average_cost => "0"
      })
  
      stock_migration.should_not be_valid
  end
  
  
  it 'should create stock_migration' do
    @stock_migration = StockMigration.create_object({
      :item_id => @item.id, 
      :quantity => 5 , 
      :average_cost => '10000'
    })
    
    @stock_migration.should be_valid 
  end
   
  
  
  context "post create" do
    before(:each) do
      @average_cost = '150000'
      @quantity = 5
       
      @item.reload 
      @initial_item_ready  = @item.ready 
      
      puts "Gonna create stock migration"
      @stock_migration = StockMigration.create_object({
        :item_id => @item.id, 
        :quantity => @quantity , 
        :average_cost => @average_cost
      })
      @item.reload 
    end
    
    it 'should auto confirm' do
      @stock_migration.should be_valid
      @stock_migration.is_confirmed.should be_true 
    end
    
    it 'should not allow duplicate migration' do
      stock_migration = StockMigration.create_object({
        :item_id => @item.id, 
        :quantity => @quantity , 
        :average_cost => @average_cost
      })
      stock_migration.should_not be_valid 
    end
    
    
    it 'should create stock_entry, stock_entry_mutation, and stock_mutation' do
      stock_entry = StockEntry.where(
        :source_document_entry_id => @stock_migration.id, 
        :source_document_entry => @stock_migration.class.to_s
      ).first 
      stock_entry.should be_valid 
      
      stock_mutation = StockMutation.where(
        :source_document_entry => @stock_migration.class.to_s, 
        :source_document_entry_id => @stock_migration.id 
      ).first 
      
      stock_mutation.should be_valid 
      
      stock_entry_mutation = StockEntryMutation.where(
        :stock_entry_id    => stock_entry.id , 
        :stock_mutation_id => stock_mutation.id  
      ).first
      
      stock_entry_mutation.should be_valid 
      
      stock_entry.creation_stock_mutation.should be_valid 
      stock_entry.creation_stock_mutation.id.should == stock_mutation.id 
    end
    
    it 'should update the item_ready quantity and inventory_value of the item' do
      @final_item_ready  = @item.ready 
      diff = @final_item_ready - @initial_item_ready
      diff.should == @quantity 
    end
    
    it 'should set the stock_entry remaining quantity to be equal with stock_migration quantity' do
      stock_entry = StockEntry.where(
        :source_document_entry_id => @stock_migration.id, 
        :source_document_entry => @stock_migration.class.to_s
      ).first 
      stock_entry.remaining_quantity.should == @quantity 
    end
    
    context "update post confirm" do
      before(:each) do
        @item.reload
        @stock_migration.reload 
        
        @new_average_cost = '150000'
        @new_quantity = 3
        
        @stock_migration.update_object(  {
          :quantity => @new_quantity,
          :average_cost => @new_average_cost 
        } )
        @item.reload
        @stock_migration.reload 
      end
      
      it 'should be valid update' do
        @stock_migration.errors.size.should == 0 
      end
      
      it 'should change the quantity in stock_entry, stock_mutation, stock_entry_mutation' do
        stock_entry = StockEntry.where(
          :source_document_entry_id => @stock_migration.id, 
          :source_document_entry => @stock_migration.class.to_s
        ).first 
        stock_entry.quantity.should == @new_quantity 
        stock_entry.remaining_quantity.should == @new_quantity 

        stock_mutation = StockMutation.where(
          :source_document_entry => @stock_migration.class.to_s, 
          :source_document_entry_id => @stock_migration.id 
        ).first 
        stock_mutation.quantity.should == @new_quantity 

        stock_entry_mutation = StockEntryMutation.where(
          :stock_entry_id    => stock_entry.id , 
          :stock_mutation_id => stock_mutation.id  
        ).first
        stock_entry_mutation.quantity.should == @new_quantity 
      end
      
      
      it 'should change the item_ready quantity' do
        @item.ready.should == @new_quantity 
      end
      it 'should change the inventory_value'
    end
    
    context "stock_entry consumption (through sales?)" do
      it 'should reduce remaining quantity'
      
      context "stock_migration quantity update [contraction]" do
      end
      
      context 'stock_migration quantity update [expansion]' do
      end
    end
  end
end
