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
      ( mutation_case.not_in StockEntryMutation.creation_mutation_cases )  & 
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
    new_object.item_id                  = item.id 
    new_object.quantity                 = quantity
    new_object.base_price_per_piece     = base_price_per_piece
    
    new_object.source_document          = document_entry.parent_document.class.to_s
    new_object.source_document_id       = document_entry.parent_document.id 
    new_object.source_document_entry    = document_entry.class.to_s 
    new_object.source_document_entry_id = document_entry.id
    
    if new_object.save
      StockEntryMutation.create_object(  stock_mutation , new_object )
    end
    
    return new_object.reload 
  end
  
  def self.update_object( document_entry,   stock_mutation   )
    stock_entry = StockEntry.where(
      :source_document_entry_id => document_entry.id, 
      :source_document_entry => document_entry.class.to_s 
    ).first 
    
    initial_quantity = stock_entry.quantity 
    initial_item = stock_entry.item 
    initial_base_price_per_piece = stock_entry.base_price_per_piece
    
    
    quantity             = StockEntry.extract_quantity( document_entry ) 
    base_price_per_piece = StockEntry.extract_base_price_per_price( document_entry )
    item                 = StockEntry.extract_item( document_entry )
    
    is_item_changed       =   (item.id != initial_item.id   )?  true : false 
    is_quantity_changed   =   (quantity != initial_quantity )? true : false 
    is_base_price_changed =   (base_price_per_piece != initial_base_price_per_piece )? true : false 
    
    if is_item_changed
      puts "Inside the is_item_changed"
      re_mapped_stock_mutation_list = stock_entry.stock_mutations 
   
      stock_entry.item_id = item.id 
      stock_entry.quantity = quantity 
      stock_entry.base_price_per_piece = base_price_per_piece
      stock_entry.save
      
      re_mapped_stock_mutation_list.each do |stock_mutation|
        StockEntryMutation.delete_object(stock_mutation)  
      end
      stock_entry.reload 
      # stock_entry.update_remaining_quantity
      re_mapped_stock_mutation_list.each do |stock_mutation|
        StockEntryMutation.create_object( stock_mutation , stock_entry  )
      end
      
      initial_item.update_ready_quantity
      item.update_ready_quantity 
      # we need to update the Inventory Price, because base price per piece is changed
      
    elsif not is_item_changed and is_quantity_changed 
      puts "the quantity changed"
      diff = quantity - initial_quantity 
     
      StockEntryMutation.update_object( stock_mutation, stock_entry ) 
      if diff > 0 # expansion
        stock_entry.base_price_per_piece = base_price_per_piece 
        stock_entry.quantity = quantity
        stock_entry.save 
        
        stock_entry.update_remaining_quantity
      else # contraction
        stock_entry.quantity = quantity
        stock_entry.base_price_per_piece = base_price_per_piece 
        stock_entry.save 
        stock_entry.shift_usage(  diff.abs  ) # the update_remaining_quantity is handled by the shift usage
        stock_entry.update_remaining_quantity 
      end
      
      item.update_ready_quantity 
    elsif not is_item_changed and not is_quantity_changed and is_base_price_changed 
      puts "the base price changed"
      stock_entry.base_price_per_piece = base_price_per_piece 
      stock_entry.save
      # only recalculate the base price 
      # item.update_inventory_price
    end
  end
  
  def self.delete_object(document_entry, stock_mutation)
    stock_entry = StockEntry.where(
      :source_document_entry => stock_mutation.source_document_entry, 
      :source_document_entry_id => stock_mutation.source_document_entry_id 
    ).first 
    
    item = stock_mutation.item 
    stock_entry.shift_usage( stock_mutation.quantity ) 
    StockEntryMutation.delete_object( stock_mutation  )
    stock_mutation.destroy 
    stock_entry.destroy 
    item.update_ready_quantity 
  end
  
   
  def update_creation_stock_entry_mutation( quantity )
    stock_entry_mutation  = self.creation_stock_entry_mutation 
    stock_entry_mutation.quantity  = quantity 
    stock_entry_mutation.save
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
  
  
=begin
  Updating stock mutation 
  
  There are 3 class of stock_mutations : creation, consumption, and sub_documents(sales_return and purchase_return) 
    
    If we update consumption (change quantity) => 
      1. Delete the current stock_entry_mutation. 
          Re map the stock_mutation    
          stock_entry.update_remaining_quantity
          item.update_ready_quantity 
    
    If we update the sales_return 
      1. delete the current stock_entry_mutation
          re map the stock_mutation 
          stock_entry.update_remaining_quantity
          item.update_ready_quantity 
          
    If we update the purchase_return
      1. delete hte current stock_entry_mutations 
        remap the stock_mutation
        stock_entry.update_remaining_quantity 
        item.update_ready_quantity
    
    If we update the creation stock_entry
      if expansion =>  increase the stock_entry_mutation quantity 
                        stock_entry.update_remaining_quantity 
                        item.update_ready_item 
                        
      if contraction => shift_usage >> amount contracted    
                        stock_entry.update_remaining_quantity 
                        item.update_ready_item 
    
    ################################ DELETION #############################
    If we delete the consumption
     1. delete the stock_entry_mutation
        delete the stock_mutation
        update all consumed stock_entries stock_entry.update_remaining_quantity
        item.update_ready_quantity 
  
    If we delete sales_return 
      1. Delete the stock_entry mutation
          delete  stock mutation 
          update all_consumed stock_entries 
          item.update_ready_quantity 
          
    If we delete purchase_return 
      1. delete the stock entry mutation
        delete the stock_mutation
        stock_entry.update_remaining_quantity
        item.update ready_quantity
        
    If we delete the creation stock_entry
      1. shift usage (all) 
        delete the stock_mutation
        delete the stock_entry_mutation
        delete the stock_entry
        item.update_ready_quantity
    
  ############################## HOW ABOUT THE CHANGE ITEM? 
  change consumption item? 
    1. delete the stock_entry_mutation
    2. all related stock_entries => stock_entry.update_remaining_quantity
    3. old item.update_ready_quantity
    4. re_map the stock_mutation 
    
  change sales_return_item? 
    1. delete the stock_entry_mutation
    2. all related stock_entries => stock_entry.update_remaining_quantity
    3. old item.update_ready_quantity
    4. re_map the stock_mutation 
    
  change purchase_return_item?   => purchase return is done on purchase receival basis 
    1. delete the stock_entry_mutation
    2. all related stock_entries => stock_entry.update_remaining_quantity
    3. old item.update_ready_quantity
    4. re_map the stock_mutation
    
  change the creation stock_entry  (if there is purchase return, don't allow)
    1. shift the usage (all)
    2. delete teh stock_entry_mutation creation
    3. recreate the stock_entry_mutation
    4. update remaining quantity of the stock_entry 
=end

  def shift_usage( quantity_to_be_shifted  )  # there is limit to the quantity to be shifted => quantity - total purchase return quantity
    # idea => we want to shift the consumption stock mutation
    # method: 1. in a stock entry, get the available quantity to be shifted. actual - purchase return 
    # 2. 
    self.is_finished = true
    self.remaining_quantity = 0 
    self.save 
   
    stock_mutation_id_to_be_re_map_list = []
    self.stock_entry_mutations.
            where(
              :mutation_case => StockEntryMutation.item_focused_consumption_mutation_cases , 
              :mutation_status => MUTATION_STATUS[:deduction]).
            order("id DESC").each do |sem|
      # for all stock_entry_mutation, get the stock_entry_mutation to be shifted
      # we want to get the associated stock_mutation so that they all can be re-mapped
      # special for sales_item_usage stock_mutation, we must re-map the sales return. 
      # get the stock mutation for the related sales return as well. 
      
      # after we have gotten all related stock_mutation, delete the stock_entry_mutations related with it
      # meanwhile, we collect the stock_entry 
      
      # after all deletion. refresh the stock_entry.remaining_quantity  
      # then, we re-map the stock_mutation 
 
      shifted_quantity = 0 
      if sem.quantity >= quantity_to_be_shifted
        shifted_quantity = quantity_to_be_shifted
      else
        shifted_quantity = sem.quantity 
      end
      
      stock_mutation_id_to_be_re_map_list << sem.stock_mutation_id 
      # adjust if there is sales return
      # must be moved together with the sales_item_usage 
      stock_mutation   = sem.stock_mutation 
      if stock_mutation.mutation_case == MUTATION_CASE[:sales_item_usage]
        # sales_return_entry_id_list = SalesReturnEntry.
        #                               where(:sales_order_entry_id => stock_mutation.source_document_entry_id).
        #                               map{|x| x.id }
        #                               
        # StockMutation.where(
        #   :source_document_entry => SalesReturnEntry.to_s,
        #   :source_document_entry_id => sales_return_entry_id_list
        # ).each {|x| stock_mutation_id_to_be_re_map_list << x.id }
      end
      
      quantity_to_be_shifted -= shifted_quantity
    end
    
    #  destroy the stock entry mutation. and refresh
    StockMutation.where(:id => stock_mutation_id_to_be_re_map_list  ).each do |stock_mutation|
      StockEntryMutation.delete_object( stock_mutation ) 
    end
    
    # related_stock_entry_id_list = [] 
    # StockEntryMutation.where(:stock_mutation_id => stock_mutation_id_to_be_re_map_list ).each do |sem|
    #   related_stock_entry_id_list << sem.stock_entry_id 
    #   sem.destroy 
    # end
    # 
    # StockEntry.where( :id => related_stock_entry_id_list).each do |stock_entry|
    #   stock_entry.update_remaining_quantity 
    # end
    
    StockMutation.where(:id => stock_mutation_id_to_be_re_map_list).order("id ASC").each do |stock_mutation|
      next if StockEntryMutation.creation_mutation_cases.include?( stock_mutation.mutation_case ) 
      next if stock_mutation.mutation_case ==  MUTATION_CASE[:purchase_return]
      
      StockEntryMutation.create_object( stock_mutation, nil )
    end
  end
  
    
  
  def self.extract_quantity( document_entry )
    if document_entry.class.to_s == "PurchaseReceivalEntry"
      return document_entry.quantity 
    end
    
    if document_entry.class.to_s == "StockMigration"
      return document_entry.quantity
    end
  end
  
  def self.extract_base_price_per_price( document_entry ) 
    if document_entry.class.to_s == "PurchaseReceivalEntry"
      return document_entry.purchase_order_entry.unit_price 
    end
    
    if document_entry.class.to_s == "StockMigration"
      return document_entry.average_cost
    end
  end
  
  def self.extract_item( document_entry ) 
    if document_entry.class.to_s == 'PurchaseReceivalEntry'
      return document_entry.purchase_order_entry.item 
    end
    
    if document_entry.class.to_s == 'StockMigration'
      return document_entry.item 
    end
  end
   
  def self.first_available_for_item( item )
    StockEntry.where(:is_finished => false, :item_id => item.id ).order('id ASC').first
  end
  
  
  # def creation_stock_entry_mutation
  #   se = self 
  #   StockEntryMutation.where{
  #     (mutation_case.in StockEntryMutation.creation_mutation_cases) & 
  #     (mutation_status.eq MUTATION_STATUS[:addition]) & 
  #     ( stock_entry_id.eq se.id )
  #   }.first 
  # end
  # 
  
  
end
