class StockEntryMutation < ActiveRecord::Base
  attr_accessible :stock_entry_id, :stock_mutation_id, :quantity , 
                  :case, :mutation_status
                  
  belongs_to :stock_entry
  belongs_to :stock_mutation 
  
  def update_quantity(quantity )
    self.quantity = quantity
    self.save 
  end
 
  def self.creation_mutation_cases
    return [
        MUTATION_CASE[:purchase_receival], # on the usage case 
        MUTATION_CASE[:stock_adjustment_addition], # on the usage case 
        MUTATION_CASE[:stock_conversion_target] 
      ]
  end
  
  def self.item_focused_consumption_mutation_cases
    return [
        MUTATION_CASE[:sales_item_usage],
        MUTATION_CASE[:sales_service_usage],
        MUTATION_CASE[:stock_conversion_source],
        MUTATION_CASE[:stock_adjustment_deduction]  
      ]
      # purchase return is not included over here.. it is not consumption..
      # it calls for re-arranging 
  end
  
  def self.item_focused_addition_mutation_cases
    return [
        MUTATION_CASE[:purchase_receival],
        MUTATION_CASE[:stock_conversion_target],
        MUTATION_CASE[:stock_adjustment_addition]  
      ]
  end
  
  def self.document_focused_addition_mutation_cases
    return [
        MUTATION_CASE[:sales_return]  # it is returning the sales_order_entry, not the item
      ]
  end
  
  def self.document_focused_consumption_mutation_cases
    return [
        MUTATION_CASE[:purchase_return] # it is returning the purchase_return_entry.. not the item
      ]
  end
   
=begin
  Flow => STOCK_MUTATION => STOCK_ENTRY => STOCK_ENTRY_MUTATION => update stock_entry remaining_quantity => update item.ready 
=end

  

  def self.create_object( stock_mutation , stock_entry) 
    if    self.item_focused_addition_mutation_cases.includes?( stock_mutation.mutation_case ) 
      self.create_addition_object(   stock_mutation, stock_entry) 
    elsif self.item_focused_consumption_mutation_cases.includes?( stock_mutation.mutation_case ) 
      self.create_consumption_object( stock_mutation  ) 
    elsif MUTATION_CASE[:purchase_return] == stock_mutation.mutation_case
      self.create_purchase_return_object( stock_mutation  )
    elsif MUTATION_CASE[:sales_return] == stock_mutation.mutation_case 
      self.create_sales_return_object( stock_mutation ) 
    end  
  end
  
  def self.create_addition_object( stock_mutation , stock_entry )
    StockEntryMutation.create(
      :stock_entry_id => stock_entry.id , 
      :stock_mutation_id => stock_mutation.id ,
      :quantity =>  stock_entry.quantity ,
      :case => stock_mutation.mutation_case  ,  
      :mutation_status =>  stock_mutation.mutation_status
    )
    
    stock_entry.update_remaining_quantity 
    item = stock_entry.item
    item.update_ready_quantity
  end
  
  def self.create_consumption_object( stock_mutation  ) 
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
        :case => stock_mutation.mutation_case  ,  
        :mutation_status =>  stock_mutation.mutation_status
      )
      
      stock_entry.update_remaining_quantity 
      quantity_to_be_disbursed -= consumed_quantity
    end
    
    item.update_ready_quantity 
  end
  
  def self.create_sales_return_object( stock_mutation  ) 
    sales_return_entry = SalesReturnEntry.find_by_id stock_mutation.source_document_entry_id 
    # find the stock_mutation for the sales_entry 
    sales_order_entry_stock_mutation = StockMutation.where(
      :source_document_entry_id => sales_return_entry.sales_order_entry.id,
      :source_document_entry => sales_return.sales_order_entry.class.to_s 
    ).first 
    
    item = stock_mutation.item 
    quantity_to_be_returned = sales_return_entry.quantity 
    
    
    sales_order_entry_stock_mutation.stock_entry_mutations.order("id DESC").each do |stock_entry_mutation|
      returned_quantity = 0 
      return nil  if quantity_to_be_returned == 0 
      
      available_quantity  =  stock_entry_mutation.quantity 
      stock_entry = stock_entry_mutation.stock_entry 
      
      if available_quantity >= quantity_to_be_returned
        returned_quantity  = quantity_to_be_returned
      else
        returned_quantity = available_quantity 
      end
      
      StockEntryMutation.create(
        :stock_entry_id => stock_entry.id , 
        :stock_mutation_id => stock_mutation.id ,
        :quantity =>  returned_quantity ,
        :case => stock_mutation.mutation_case  ,  
        :mutation_status =>  stock_mutation.mutation_status
      )
      
      quantity_to_be_returned -= returned_quantity 
      stock_entry.update_remaining_quantity 
    end
    item.update_ready_quantity 
  end
  
  def self.create_purchase_return_object( stock_mutation, stock_entry ) 
    # purchase_return is linked to the purchase_order 
    # however, the physical item received is through purchase_receival. How can we solve for it? 
    # 
    purchase_return_entry = PurchaseReturnEntry.find_by_id stock_mutation.source_document_entry_id 
    
    # we need to get all purchase receival associated with this purchase_order_entry 
    purchase_receival_entry_id_list = [] 
    PurchaseReceivalEntry.where(
      :purchase_order_entry_id => purchase_return_entry.purchase_order_entry_id 
    ).each do |purchase_receival_entry|
      purchase_receival_entry_id_list << purchase_receival_entry.id 
    end
    
    item = stock_mutation.item 
    quantity_to_be_returned = stock_mutation.quantity 
    
    
    StockMutation.where(
      :source_document_entry_id => purchase_receival_entry_id_list ,
      :source_document_entry => PurchaseReceivalEntry.to_s 
    ).order("id DESC").each do |purchase_receival_stock_mutation|
      
      return nil if quantity_to_be_returned == 0 
      
      # stock_entry = purchase_receival_stock_mutation.stock_entries.first # addition only have 1 stock_entry 
      stock_entry = StockEntry.where(
        :source_document_entry_id => purchase_receival_stock_mutation.source_document_entry_id, 
        :source_document_entry_id => purchase_receival_stock_mutation.source_document_entry 
      ).first 
      
      # for every purchase_receival stock_entry.. add the purchase_return_stock_entry_mutation 
      purchase_return_quantity = 0 
      if stock_entry.quantity >= quantity_to_be_returned
        purchase_return_quantity = quantity_to_be_returned
      else
        purchase_return_quantity = stock_entry.quantity
      end
      
      StockEntryMutation.create(
        :stock_entry_id => stock_entry.id , 
        :stock_mutation_id => stock_mutation.id ,
        :quantity =>  purchase_return_quantity ,
        :case => stock_mutation.mutation_case  ,  
        :mutation_status =>  stock_mutation.mutation_status
      )
      
      quantity_to_be_returned -= purchase_return_quantity
      stock_entry.refresh_usage
    end
    
    item.update_ready_quantity 
  end
  
  
  # we will be using stock_entry.refresh_usage a lot for update and delete
  
  
   
end
