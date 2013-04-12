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
    # if excess_quantity == 0 
    #   self.remaining_quantity = 0 
    #   self.is_finished = true 
    #   self.save
    # elsif excess_quantity > 0
    #   self.remaining_quantity = excess_quantity  
    #   self.is_finished = false 
    #   self.save 
    # elsif excess_quantity  < 0 
    #   self.shift_stock_usage 
    # end
  end
  
  # use case: on update stock_entry , update sales data , or update
  # stock_mutation.quantity = 5 
  # stock_entry.quantity = 5
  def refresh_stock_usage( stock_mutation ) 
    stock_mutation_list = self.stock_mutations
    
    stock_mutation_list = self.stock_mutations.where{
      ( id.gte stock_mutation.id  )
    }.order("id ASC")
    
    stock_mutation_id_list  = stock_mutation_list.map{|x| x.id }
    
    # re-perform the stock_mutation ( stock mutation is our time line.. it tracks the item mutation)
    # stock entry is the costing mechanism 
    affected_stock_entry_id_list = [] 
    StockEntryMutation.where(:stock_mutation_id => stock_mutation_id_list ).each do |x|
      affected_stock_entry_id_list << x.stock_entry_id 
      x.destroy 
    end
    
    affected_stock_entry_id_list.uniq! 
    StockEntryMutation.create_object( stock_mutation_list )
  end
  
  def shift_stock_usage
    self.is_finished = true
    self.remaining_quantity = 0 
    self.save
    
    excess_quantity = self.calculated_remaining_quantity *( -1 )
    # take stock_entry_mutations with total quantity == 3 or more 
    StockEntryMutation.distribute_excess_quantity( self, excess_quantity ) 
  end
  
  def calculated_remaining_quantity 
    addition  = self.stock_entry_mutations.where(:mutation_status =>  MUTATION_STATUS[:addition] ).sum('quantity')
    deduction = self.stock_entry_mutations.where(:mutation_status =>  MUTATION_STATUS[:deduction] ).sum('quantity')
    
    return addition - deduction 
  end
  
  def operational_usage_stock_entry_mutations
    # self.stock_entry_mutations.where(
    #   :case => StockEntryMutation.operational_usage_mutation_cases,
    #   :mutation_status => MUTATION_STATUS[:deduction]
    # ).order("id DESC")
    # 
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
  
  def self.update_object( stock_mutation, document_entry ) 
    new_item     = self.extract_item( document_entry )
    new_quantity = self.extract_quantity( document_entry )
    stock_entry  = self.get_stock_entry( document_entry ) 
   
    is_item_changed = stock_entry.item_id != new_item.id ? true : false 
    is_quantity_changed = stock_entry.quantity != new_quantity ? true : false 
    
    if is_item_changed 
      # current_item = stock_entry.item 
      current_item = stock_entry.item 
      
      # stock_entry.refresh_initial_quantity 
      # stock_entry.replay_stock_mutation_history 
      stock_entry.shift_usage( document_entry   )
      
      stock_entry.item_id = item.id 
      stock_entry.update_remaining_quantity
      
      new_item.update_ready_quantity 
      current_item.update_ready_quantity
      
      
      # stock_entry.destroy # there is mechanism of shifting the usage to the next available shite 
      # current_item.update_ready_quantity 
      
      # create new stock entry + its associated stock
      
      # generic case: the stock entry has been used 
      # in the update validation => we need to find out whether the total item ready without this 
      #   stock_entry will be logical ( not minus ). if yes => go on.. if not, it is a false condition.. no update is allowed 
      # 1. shift the current usage to another stock entry 
        # =>  which means: no other stock_entry_mutation linked to this current stock_entry other than the creation linkage 
      # 2. change the item_id in the stock_entry 
      #   2.1 update the creation quantity in the stock_entry_mutation 
      # 3. update the remaining quantity of this stock_entry 
      # 4. update the item ready in the current stock_entry and the target stock_entry 
    end
    
    if not is_item_changed and is_quantity_changed 
    end
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
  
  def shift_usage( quantity  ) 
    
    # how many quantity to be shifted. if it happened that there are sales stock_mutation.. get the associated
    # sales_return entry.. remap them. 
    
    # if the usage consumption spanned more than 1 stock_entry, severe the tie with another stock_entries
    # remap the stock_mutation
    self.is_finished = true
    self.remaining_quantity = 0 
    self.save 
    
    # stock_entry composition
    # 1. 1 item_focused_addition_mutation_cases
    # 2. several item_focused_consumption_mutation_cases => must be moved
    # 3. several document_focused_addition_mutation_cases => must follow the original document (item_focused consumption)
    # 4. several document_focused_consumption_mutation_cases => must follow original document
    
    # port the item_focused consumption 
    self.stock_mutations.where{
      mutation_case.in StockEntryMutation.item_focused_consumption_mutation_cases
    }.each do |stock_mutation|
      StockEntryMutation.update_consumption( stock_mutation )
    end
    
    # for the sales return
    # self.stock_mutations.where( :mutation_case => MUTATION_CASE[:sales_return] ).each do |x|
    #   StockEntryMutation.update_consumption( x )
    #   # x.update_consumption( stock_mutation )
    # end
    
    # we must do the one for the purchase_return
  end
  
  
  def delete_creation_stock_entry 
  end
  
  def self.get_stock_entry( document_entry ) 
    StockEntry.where(
      :source_document_entry => document_entry.class.to_s, 
      :source_document_entry_id => document_entry.id 
    ).first 
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
      new_object.update_creation_stock_mutation
    end
  end
  
  
  def update_from_document_entry( document_entry, quantity, base_price_per_piece )
    self.quantity             = quantity
    self.base_price_per_piece = base_price_per_piece
    self.save
    self.update_creation_stock_mutation
  end
 
 
  def self.first_available_for_item( item )
    StockEntry.where(:is_finished => false, :item_id => item.id ).order('id ASC').first
  end
  
  
  
end
