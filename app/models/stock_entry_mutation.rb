class StockEntryMutation < ActiveRecord::Base
  attr_accessible :stock_entry_id, :stock_mutation_id, :quantity , 
                  :case, :mutation_status
                  
  belongs_to :stock_entry
  belongs_to :stock_mutation 
  
  def update_quantity(quantity )
    self.quantity = quantity
    self.save 
  end
  
  def self.operational_usage_mutation_case
    return [
        MUTATION_CASE[:stock_conversion],
        MUTATION_CASE[:stock_adjustment],
        MUTATION_CASE[:sales]
      ]
  end
  
  def self.distribute_excess_quantity( stock_entry, excess_quantity )
    stock_entry.operational_usage_stock_entry_mutations.each do |stock_entry_mutation|
      
      return if excess_quantity ==  0 
      
      if stock_entry_mutation.quantity  >= excess_quantity 
        stock_entry_mutation.reassign_by_quantity( stock_entry, excess_quantity ) 
      else
        stock_entry_mutation.reassign_by_quantity( stock_entry, stock_entry_mutation.quantity ) 
        excess_quantity -= stock_entry_mutation.quantity 
      end
    end
  end
  
  def reassign_by_quantity(stock_entry, excess_quantity)
    stock_mutation = self.stock_mutation 
    # we start with 1.. it can lead to one single stock entry
    # or it can be coming from 2 different stock_entries 
    first_change = false 
    while excess_quantity != 0  
      available_stock_entry = StockEntry.first_available_for_item( stock_entry.item )
      
      
      if first_change == false   # it means that the initial stock_entry_mutation has not been re-pointed 
        if available_stock_entry.quantity >= excess_quantity 
          self.stock_entry_id = available_stock_entry.id 
          self.quantity = excess_quantity 
          self.save 
        else 
          # the initial stock_entry_mutation has been repointed.. 
          # But the new container quantity is less than the stock_entry_mutation quantity
          self.stock_entry_id = available_stock_entry.id 
          self.quantity = available_stock_entry.quantity 
          self.save 
        end
      else
        quantity = excess_quantity 
        if available_stock_entry.quantity >= excess_quantity 
          quantity = excess_quantity 
        else
          quantity = available_stock_entry.quantity 
        end
        
        StockEntryMutation.create(
          :stock_entry_id => available_stock_entry.id , 
          :stock_mutation_id => stock_mutation.id ,
          :quantity =>  quantity ,
          :case => self.case  ,  
          :mutation_status =>  self.mutation_status 
        )
      end
      
      
      available_stock_entry.update_remaining_quantity
      first_change = true 
    end
    
  end
  
  
end
