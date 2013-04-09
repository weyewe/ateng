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
  
  
# Used for stock_entry contraction or expansion
  # on construction case, redistribution of excess quantity will be performed 
  def self.distribute_excess_quantity( stock_entry, excess_quantity )
    
    # operational usage => 1, 2 , 3 ,4 ,5 
    # frmo the last usage, reassign it 
    stock_entry.operational_usage_stock_entry_mutations.each do |stock_entry_mutation|
      
      return if excess_quantity ==  0 
      
      distributed_quantity = 0 
      if stock_entry_mutation.quantity  >= excess_quantity 
        distributed_quantity = excess_quantity
      else 
        distributed_quantity = stock_entry_mutation.quantity 
      end
      
      stock_entry_mutation.reassign_by_quantity( stock_entry, excess_quantity ) 
      excess_quantity -= distributed_quantity
    end
  end
  
  def reassign_by_quantity(stock_entry, excess_quantity)
    stock_mutation = self.stock_mutation 
    # we start with 1.. it can lead to one single stock entry
    # or it can be coming from 2 different stock_entries 
    first_change = true 
    while excess_quantity != 0  
      available_stock_entry = StockEntry.first_available_for_item( stock_entry.item )
      reassigned_quantity = 0 
      
      if first_change == true   # it means that the initial stock_entry_mutation has not been re-pointed 
        if available_stock_entry.remaining_quantity >= excess_quantity 
          self.stock_entry_id = available_stock_entry.id 
          self.quantity = excess_quantity 
          self.save 
          reassigned_quantity = excess_quantity
        else 
          # the initial stock_entry_mutation has been repointed.. 
          # But the new container quantity is less than the stock_entry_mutation quantity
          self.stock_entry_id = available_stock_entry.id 
          self.quantity = available_stock_entry.remaining_quantity 
          self.save 
          reassigned_quantity = available_stock_entry.remaining_quantity 
        end
      else
        if available_stock_entry.remaining_quantity >= excess_quantity 
          reassigned_quantity = excess_quantity 
        else
          reassigned_quantity = available_stock_entry.remaining_quantity 
        end
        
        StockEntryMutation.create(
          :stock_entry_id => available_stock_entry.id , 
          :stock_mutation_id => stock_mutation.id ,
          :quantity =>  remaining_quantity ,
          :case => self.case  ,  
          :mutation_status =>  self.mutation_status 
        )
      end
      
      excess_quantity -= reassigned_quantity 
      
      available_stock_entry.update_remaining_quantity
      first_change = false 
    end  # the while excess_quantity != 0 
    
  end
  
  
# used for stock_entry consumption 
  def self.create_consumption( stock_mutation ) 
    quantity_to_be_disbursed = stock_mutation.quantity 
    item = stock_mutation.item 
    
    while quantity_to_be_disbursed != 0 
      stock_entry = StockEntry.first_available_for_item( item )
      
      if stock_entry.remaining_quantity >= quantity_to_be_disbursed
        consumed_quantity = quantity_to_be_disbursed
      else
        consumed_quantity = stock_entry.remaining_quantity
      end
      
      StockEntryMutation.create(
        :stock_entry_id => stock_entry.id , 
        :stock_mutation_id => stock_mutation.id ,
        :quantity =>  consumed_quantity ,
        :case => stock_mutation.case  ,  
        :mutation_status =>  stock_mutation.mutation_status
      )
      
      stock_entry.update_remaining_quantity 
      quantity_to_be_disbursed -= consumed_quantity
    end
    
    item.update_ready_quantity 
  end
  
  def self.update_consumption( stock_mutation ) 
    stock_entries       = self.stock_entries 
    is_item_changed     = false 
    is_quantity_changed = false 
    item = stock_entries.first.item 
    
    if stock_entries.first.item_id != stock_mutation.item_id 
      is_item_changed = true 
    end
    
   
    stock_mutation.stock_entry_mutations.each do |stock_entry_mutation|
      stock_entry = stock_entry_mutation.stock_entry
      stock_entry.update_remaining_quantity
      stock_entry_mutation.destroy 
    end
    
    self.create_consumption( stock_mutation )
    
    if is_item_changed
      item.update_ready_quantity
    end
  end
  
  
end
