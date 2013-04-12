class StockEntry < ActiveRecord::Base
  has_many :stock_entry_mutations
  has_many :stock_mutations, :through => :stock_entry_mutations
  # attr_accessible :title, :body
  belongs_to :item 
  
  validates_presence_of :item_id , :quantity, :base_price_per_piece
  
  # for quantity update (Tracking FIFO price)
  # after_save :update_creation_stock_mutation   
  
  def update_creation_stock_mutation
    self.creation_stock_mutation.update_quantity( self.quantity ) 
    self.creation_stock_entry_mutation.update_quantity( self.quantity )
    self.update_ready_quantity 
  end
  
  def update_ready_quantity
    self.update_remaining_quantity 
    self.reload
    item = self.item
    item.update_ready_quantity
  end
  
  def update_remaining_quantity 
    remaining_quantity  = self.calculated_remaining_quantity
    
    if remaining_quantity == 0 
      self.remaining_quantity = 0 
      self.is_finished = true
    else
      self.remaining_quantity = remaining_quantity
      self.is_finished = false 
    end
    self.save 
  end
  
  
  
  def calculated_remaining_quantity 
    addition  = self.stock_entry_mutations.where(:mutation_status =>  MUTATION_STATUS[:addition] ).sum('quantity')
    deduction = self.stock_entry_mutations.where(:mutation_status =>  MUTATION_STATUS[:deduction] ).sum('quantity')
    
    return addition - deduction 
  end
  
  def operational_usage_stock_entry_mutations

    self.stock_entry_mutations.where{
      ( case.not_in StockEntryMutation.creation_mutation_cases )  & 
      ( mutation_status.eq MUTATION_STATUS[:deduction] )
    }.order("id DESC")
  end
  
   
   
=begin
  Documents that triggers stock entry creation:
  1. Stock migration
  2. Purchase Receival 
  3. StockAdjustment ( can be creation or usage )
=end
   
   
  
  def self.create_object( document_entry  ,  stock_mutation) 
    quantity             = self.extract_quantity( document_entry ) 
    base_price_per_piece = self.extract_base_price_per_price( document_entry )
    item                 = self.extract_item( document_entry ) 

    new_object                          = self.new 
    new_object.item_id                  = item_id
    new_object.quantity                 = quantity
    new_object.base_price_per_piece     = base_price_per_piece
    
    new_object.source_document          = document_entry.parent_document.class.to_s
    new_object.source_document_id       = document_entry.parent_document.id 
    new_object.source_document_entry    = document_entry.class.to_s 
    new_object.source_document_entry_id = document_entry.id
    
    new_object.save
    return new_object 
  end
   
   
=begin
  Handling purchase return, contraction 
=end
  
  
  # to recalculate the stock mutation on a given stock_entry
  # but refresh usage is not practical.. we will need to do many execution
  # what if we shift the consumption stock_entry_mutation? 
  def refresh_usage
    # all stock mutations associated with the stock entries 
    stock_mutations = self.stock_mutations.order('id ASC')
    # if there is sales, bring along the sales return stock mutation 
    related_stock_mutation_id_list = self.stock_mutations.map{|x| x.id }
    sales_item_id_list = stock_mutations.
                    where(:mutation_case == MUTATION_CASE[:sales_item_usage]). # sales_item_usage can have sales_return 
                    map {|x| x.source_document_entry_id }
  
    related_sales_return_entry_id_list = [] 
    SalesOrderEntry.where(:id => sales_item_id_list).each do |sales_order_entry|
      sales_order_entry.sales_return_entries.each do |sre|
        related_sales_return_entry_id_list << sre.id 
      end
    end
    
    sales_return_stock_mutation_id_list = StockMutation.where(
      :source_document_entry => SalesReturnEntry.to_s , 
      :source_document_entry_id => related_sales_return_entry_id_list
    ).map {|x| x.id }
    
    all_stock_mutation_id_list = sales_return_stock_mutation_id_list + related_stock_mutation_id_list
    all_stock_mutation_id_list.uniq! 
    
    related_stock_mutations = StockMutation.where( :id => all_stock_mutation_id_list ).order("id ASC")

    related_stock_mutations.each do |stock_mutation|
      next if StockEntryMutation.creation_mutation_cases.include?( stock_mutation.mutation_case ) 
      next if stock_mutation.mutation_case ==  MUTATION_CASE[:purchase_return]
      
      stock_entries = stock_mutation.stock_entries 
      stock_mutation.stock_entry_mutations.each do |sem|
        sem.destroy 
      end
      
      # if stock_mutation create n stock_entry_mutation(s), scattered across several stock_entries 
      stock_entries.each do |se|
        next if se.id == self.id 
        se.update_remaining_quantity 
      end
    end
    
    self.update_remaining_quantity 
    
    # gonna replay the stock mutation => create the stock entry mutation,
    # except for purchase return and purchase receival 
    related_stock_mutations.each do |stock_mutation|
      next if StockEntryMutation.creation_mutation_cases.include?( stock_mutation.mutation_case ) 
      next if stock_mutation.mutation_case ==  MUTATION_CASE[:purchase_return]
      
      StockEntryMutation.create_object( stock_mutation, nil ) 
    end
  end
  
  def shift_usage( quantity_to_be_shifted  ) 
    self.is_finished = true
    self.remaining_quantity = 0 
    self.save 
   
    stock_mutation_to_be_re_map_list = []
    self.stock_entry_mutations.
            where(
              :case => StockEntryMutation.item_focused_consumption_mutation_cases , 
              :mutation_status => MUTATION_STATUS[:deduction]).
            order("id DESC").each do |sem|
        
      shifted_quantity = 0 
      if sem.quantity >= quantity_to_be_shifted
        shifted_quantity = quantity_to_be_shifted
      else
        shifted_quantity = sem.quantity 
      end
      
      stock_mutation_id_to_be_re_map_list << sem.stock_mutation.id 
      if stock_mutation.mutation_case == MUTATION_CASE[:sales_item_usage]
        sales_return_entry_id_list = SalesReturnEntry.
                                      where(:sales_order_entry_id => stock_mutation.source_document_entry_id).
                                      map{|x| x.id }
                                      
        StockMutation.where(
          :source_document_entry => SalesReturnEntry.to_s,
          :source_document_entry_id => sales_return_entry_id_list
        ).each {|x| stock_mutation_id_to_be_re_map_list << x.id }
      end
      
      quantity_to_be_shifted -= shifted_quantity
      
    end
    
    #  destroy the stock entry mutation. and refresh
    StockEntryMutation.where(:stock_mutation_id => stock_mutation_id_to_be_re_map_list ).each do |sem|
      stock_entry = sem.stock_entry
      sem.destroy 
      stock_entry.update_remaining_quantity  if stock_entry.id != self.id 
    end
    
    self.update_remaining_quantity 
    
    StockMutation.where(:id => stock_mutation_id_to_be_re_map_list).each do |stock_mutation|
      StockEntryMutation.create_object( stock_mutation, nil )
    end
    
  end
  
    
  
  def self.extract_quantity( document_entry )
    if document_entry.class.to_s == "PurchaseReceivalEntry"
      return document_entry.quantity 
    end
  end
  
  def self.extract_base_price_per_piece( document_entry ) 
    if document_entry.class.to_s == "PurchaseReceivalEntry"
      return document_entry.purchase_order_entry.unit_price 
    end
  end
  
  def self.extract_item( document_entry ) 
    if document_entry.class.to_s = 'PurchaseReceivalEntry'
      return document_entry.purchase_order_entry.item 
    end
  end
   
  def self.first_available_for_item( item )
    StockEntry.where(:is_finished => false, :item_id => item.id ).order('id ASC').first
  end
  
  
  
end
