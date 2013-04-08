class StockEntryMutation < ActiveRecord::Base
  attr_accessible :stock_entry_id, :stock_mutation_id, :quantity , 
                  :case, :mutation_status
                  
  belongs_to :stock_entry
  belongs_to :stock_mutation 
  
  def update_quantity(quantity )
    self.quantity = quantity
    self.save 
  end
end
