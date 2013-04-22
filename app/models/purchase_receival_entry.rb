class PurchaseReceivalEntry < ActiveRecord::Base
  include StockMutationDocumentEntry
  include StockEntryDocumentEntry
  # attr_accessible :title, :body
  belongs_to :purchase_receival
  belongs_to :purchase_order_entry
  belongs_to :item 
  belongs_to :supplier 
    
  
  validates_presence_of :item_id  
  validates_presence_of :quantity  
  validates_presence_of :purchase_order_entry_id 
  has_many :purchase_receival_entries
  
   
  validate :quantity_must_not_less_than_zero 
  validate :quantity_must_not_exceed_the_ordered_quantity
  validate :entry_uniqueness 
  
  after_save :update_item_pending_receival, :update_purchase_order_entry_fulfilment_status #, :update_item_statistics
  after_destroy :update_item_pending_receival , :update_purchase_order_entry_fulfilment_status # , :update_item_statistics
  
  def update_item_pending_receival
    item = self.item 
    item.reload 
    item.update_pending_receival
  end
  
  # def update_item_statistics
  #   # return nil if not self.is_confirmed? 
  #   item = self.item 
  #   item.reload
  #   item.update_ready_quantity
  # end
  
  def update_purchase_order_entry_fulfilment_status
    purchase_order_entry = self.purchase_order_entry 
    purchase_order_entry.reload 
    purchase_order_entry.update_fulfillment_status
    # what if they change the purchase_order_entry
  end
     
  def quantity_must_not_less_than_zero
    if quantity.present? and quantity <= 0 
      msg = "Kuantitas  tidak boleh 0 atau negative "
      errors.add(:quantity , msg )
    end
  end
     
  def quantity_must_not_exceed_the_ordered_quantity
    return nil if self.purchase_order_entry.nil? 
    # return nil if self.is_confirmed? 
    
    purchase_order_entry = self.purchase_order_entry 
    
    pending_receival = purchase_order_entry.pending_receival
    if not self.is_confirmed? 
      if  self.quantity > pending_receival 
        errors.add(:quantity , "Max penerimaan untuk item dari purchase order ini: #{pending_receival}" )
      end
    else
      initial_received = StockMutation.where(
        :source_document_entry => "PurchaseReceivalEntry",
        :source_document_entry_id => self.id 
      ).first 
      
      return nil if initial_received.nil? 
      
      # puts "Inside the purchase_receival_entry, validation\n"*10
      actual_pending_receival =  pending_receival + initial_received.quantity 
      # puts "actual_pending_receival: #{actual_pending_receival}"
      if  self.quantity > actual_pending_receival
        errors.add(:quantity , "Max penerimaan untuk item dari purchase order ini: #{actual_pending_receival}" )
      end
    end
  end   
  
  def entry_uniqueness
    purchase_order_entry = self.purchase_order_entry 
    return nil if purchase_order_entry.nil? 
    
    parent = self.purchase_receival 
    
   
    purchase_receival_entry_count = PurchaseReceivalEntry.where(
      :purchase_order_entry_id => self.purchase_order_entry_id,
      :purchase_receival_id => parent.id  
    ).count 
    
    item = purchase_order_entry.item 
    purchase_order = purchase_order_entry.purchase_order
    msg = "Item #{item.name} dari pemesanan #{purchase_order.code} sudah terdaftar di penerimaan ini"
    
    if not self.persisted? and purchase_receival_entry_count != 0
      errors.add(:purchase_order_entry_id , msg ) 
    elsif self.persisted? and not self.purchase_order_entry_id_changed? and purchase_receival_entry_count > 1
      errors.add(:purchase_order_entry_id , msg ) 
    elsif self.persisted? and self.purchase_order_entry_id_changed? and purchase_receival_entry_count != 0 
      errors.add(:purchase_order_entry_id , msg ) 
    end
  end
     
  
  
  def delete_object
    if not self.is_confirmed?
      self.destroy 
      return nil 
    end
    
    return nil if self.is_deleted? 
    
    ActiveRecord::Base.transaction do
      
      self.is_deleted = true 
      self.save
      StockMutation.delete_object( self )  
      # StockEntry.delete_object( self, stock_mutation)
      
    end
  end
  
  
  
 
  
  
  
  def self.create_object( purchase_receival, params ) 
    return nil if purchase_receival.nil? 
    purchase_order_entry = PurchaseOrderEntry.find_by_id params[:purchase_order_entry_id]
    
    new_object = self.new
    new_object.supplier_id = purchase_receival.supplier_id 
    
    new_object.purchase_receival_id = purchase_receival.id 
    new_object.purchase_order_entry_id = purchase_order_entry.id 
    new_object.quantity                = params[:quantity]       
    new_object.item_id                 = purchase_order_entry.item_id   
    
    if new_object.save 
      new_object.generate_code 
    end
    
    return new_object 
  end
  
  def update_object( params ) 
    
      purchase_order_entry = PurchaseOrderEntry.find_by_id params[:purchase_order_entry_id]    
      self.purchase_order_entry_id = purchase_order_entry.id 
      self.quantity                = params[:quantity]       
      self.item_id                 = purchase_order_entry.item_id
 
      
      ActiveRecord::Base.transaction do
        if self.save 
          StockMutation.create_or_update_purchase_receival_stock_mutation( self ) if self.is_confirmed?
        end
      end
   
    
    return self 
  end
  
  
  
  def generate_code
    start_datetime = Date.today.at_beginning_of_month.to_datetime
    end_datetime = Date.today.next_month.at_beginning_of_month.to_datetime
    
    counter = self.class.where{
      (self.created_at >= start_datetime)  & 
      (self.created_at < end_datetime )
    }.count
    
    if self.is_confirmed?
      counter = self.class.where{
        (self.created_at >= start_datetime)  & 
        (self.created_at < end_datetime ) & 
        (self.is_confirmed.eq true )
      }.count
    end
    
    header = ""
    if not self.is_confirmed?  
      header = "[pending]"
    end
    
    string = "#{header}PRCE" + 
              ( self.created_at.year%1000).to_s + "-" + 
              ( self.created_at.month).to_s + '-' + 
              ( counter.to_s ) 
              
    
    self.code =  string 
    self.save 
  end
   
  def confirm
    return nil if self.is_confirmed == true 
    self.is_confirmed = true 
    self.save
    self.generate_code 
    self.reload 
    
    # create  stock_entry and the associated stock mutation 
    # StockEntry.generate_purchase_receival_stock_entry( self  ) 
    # StockMutation.generate_purchase_receival_stock_mutation( self  ) 
    StockMutation.create_or_update_purchase_receival_stock_mutation( self ) 
  end
  
  def parent_document
    self.purchase_receival
  end
  
end
