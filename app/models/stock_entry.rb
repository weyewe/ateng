class StockEntry < ActiveRecord::Base
  has_many :stock_entry_mutations
  has_many :stock_mutations, :through => :stock_entry_mutations
  # attr_accessible :title, :body
  belongs_to :item 
  
  validates_presence_of :item_id , :quantity, :base_price_per_piece
  
  after_save :update_creation_stock_mutation   
  
  def update_creation_stock_mutation
    if self.quantity != self.creation_stock_mutation.quantity 
      self.creation_stock_mutation.update_quantity( self.quantity ) 
      self.creation_stock_entry_mutation.update_quantity( self.quantity )
      self.update_remaining_quantity 
      self.reload 
      item = self.item
      item.update_inventory_cost  # remaining inventory cost 
      item.update_ready_quantity  # how many do we have in hand? 
    end
  end
  
  def update_remaining_quantity 
    excess_quantity = self.calculated_remaining_quantity
    
    
    if excess_quantity == 0 
      self.remaining_quantity = 0 
      self.is_finished = true 
      self.save
    elsif excess_quantity > 0
      self.excess_quantity = 0  
      self.is_finished = false 
      self.save 
    elsif excess_quantity  < 0 
      self.shift_stock_usage 
    end
  end
  
  def shift_stock_usage
    excess_quantity = self.calculated_remaining_quantity *( -1 )
    
    self.is_finished = true
    self.remaining_quantity = 0 
    self.save 
  end
  
  def calculated_remaining_quantity 
    addition  = self.stock_entry_mutations.where(:mutation_status =>  MUTATION_STATUS[:addition] ).sum('quantity')
    deduction = self.stock_entry_mutations.where(:mutation_status =>  MUTATION_STATUS[:deduction] ).sum('quantity')
    
    return addition - deduction 
  end
  
   
   
=begin
  Documents that triggers stock entry creation:
  1. Stock migration
  2. Purchase Receival 
  3. StockAdjustment ( can be creation or usage )
=end
  def creation_stock_mutation
    StockMutation.where(
      :source_document_entry_id => self.source_document_entry_id  , 
      :source_document_entry => self.source_document_entry 
    ).first 
  end
  
  def creation_stock_entry_mutation
    StockEntryMutation.where(
      :stock_entry_id => self.id , 
      :stock_mutation_id => self.creation_stock_mutation.id
    ).first 
  end
  
  
  def self.generate_from_document_entry( document_entry, quantity, base_price_per_piece ) 
    new_object = self.new 
    new_object.item_id = document_entry.item_id
    new_object.source_document          = document_entry.parent_document.class.to_s
    new_object.source_document_id       = document_entry.parent_document.id 
    
    new_object.source_document_entry    = document_entry.class.to_s 
    new_object.source_document_entry_id = document_entry.id
    
    new_object.quantity                 = quantity
    new_object.base_price_per_piece     = base_price_per_piece
    
    if new_object.save 
      StockMutation.generate_from_document_entry(new_object, document_entry ) 
    end
  end
  
  
  def update_from_document_entry( document_entry, quantity, base_price_per_piece )
    self.quantity             = quantity
    self.base_price_per_piece = base_price_per_piece
    self.save
    
    self.reload 
  end
 
  
  
  
end
