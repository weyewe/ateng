class StockEntry < ActiveRecord::Base
  has_many :stock_entry_mutations
  has_many :stock_mutations, :through => :stock_entry_mutations
  # attr_accessible :title, :body
  
  validates_presence_of :item_id , :quantity, :base_price_per_piece
  
  def self.generate_from_stock_migration( stock_migration ) 
    new_object                      = self.new 
    
    new_object.item_id                  = stock_migration.item_id 
    new_object.source_document          = stock_migration.class.to_s
    new_object.source_document_id       = stock_migration.id 
    new_object.source_document_entry    = stock_migration.class.to_s 
    new_object.source_document_entry_id = stock_migration.id

    new_object.quantity                 = stock_migration.quantity 
    new_object.base_price_per_piece     = stock_migration.average_cost 
    
    if new_object.save 
      # generate the creation stock_mutation  and its accompanying stock_entry_mutation 
    end
  end
  
  def update_from_stock_migration( stock_migration ) 
    
    is_quantity_changed = false 
    is_quantity_changed = self.quantity != stock_migration.quantity 
    is_price_changed = false 
    is_price_changed = self.base_price_per_piece != stock_migration.average_cost 
    
    initial_quantity = self.quantity 
    initial_price = self.base_price_per_piece 
    
    self.quantity             = stock_migration.quantity
    self.base_price_per_piece = stock_migration.average_cost 
    
    if self.save 
      # cases: expansion or contraction 
      
      # if contraction => we have a problem: 
      # if the final quantity is less than initial quantity, and usage overflowing, 
      # we need to shift the overflown usage => shifting the stock_entry_mutation 
      
      
      if is_quantity_changed  or is_price_changed 
        # update the total_item_ready 
        # update total_inventory_amount 
      end
      
      
      # handle the creation stock_mutation
      # handle the usage stock_mutation 
    end
  end
end
