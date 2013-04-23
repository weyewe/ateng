=begin
  Pending: if it is possible, don't allow the completed receival to be received 
  or not even being shown 
=end

class PurchaseOrderEntry < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :purchase_order
  belongs_to :item 
  belongs_to :supplier 
  has_many :purchase_receival_entries 
    
  
  validates_presence_of :item_id  
  validates_presence_of :quantity  
  
  validate :valid_item

  validate :entry_uniqueness 
  validate :quantity_must_not_less_than_zero 
  
  after_save :update_item_pending_receival  
  after_destroy :update_item_pending_receival

  def valid_item
    if self.item.nil?
      errors.add(:item_id, "Harus diisi")
    end
  end
  

  def entry_uniqueness
    return if self.item.nil? 
    
    parent = self.purchase_order
    purchase_order_entry_count = PurchaseOrderEntry.where(
      :item_id => self.item_id,
      :purchase_order_id => parent.id  
    ).count 
    
    item = self.item 
    purchase_order = self.purchase_order
    msg = "Item #{item.name} dari pemesanan #{purchase_order.code} sudah terdaftar di penerimaan ini"
 
    if not self.persisted? and purchase_order_entry_count != 0
      errors.add(:item_id , msg ) 
    elsif self.persisted? and not self.item_id_changed? and purchase_order_entry_count > 1 
      errors.add(:item_id , msg ) 
    elsif self.persisted? and  self.item_id_changed? and purchase_order_entry_count  != 0 
      errors.add(:item_id , msg )
    end
   
  end
 
  # this is called when there is change in the purchase_receival_entry#purchase_order_entry
  # or the purchase_order_entry 's quantity is changed 
  def update_fulfillment_status
    if self.is_confirmed? 
      self.reload
      fulfilled = self.purchase_receival_entries.where(:is_confirmed => true).sum("quantity")
      if fulfilled >= self.quantity
        self.is_fulfilled = true 
        self.save 
      else
        self.is_fulfilled = false
        self.save 
      end
    end
  end
  
  def update_item_pending_receival
    item = self.item 
    return if item.nil? 
    item.reload 
    item.update_pending_receival
  end
     
  def quantity_must_not_less_than_zero
    if quantity.present? and quantity <= 0 
      msg = "Kuantitas  tidak boleh 0 atau negative "
      errors.add(:quantity , msg )
    end
  end
     
  def delete_object 
    if self.is_confirmed?   
      ActiveRecord::Base.transaction do
        self.post_confirm_delete
        return self
      end
    end
    
    self.destroy 
  end
  
  def post_confirm_delete 
    if self.purchase_receival_entries.count != 0 
      self.errors.add(:generic_errors , "Sudah ada penerimaan barang" )
      return self
    end 
 
    self.destroy 
  end
  
  
  
  def self.create_object( purchase_order, params ) 
    return nil if purchase_order.nil? 
    
    new_object = self.new
    new_object.purchase_order_id = purchase_order.id 
    
    new_object.quantity           = params[:quantity]       
    new_object.item_id     = params[:item_id]     
    
    if new_object.save 
      new_object.generate_code 
    end
    
    return new_object 
  end
  
  def update_object( params ) 
    if self.is_confirmed? 
      ActiveRecord::Base.transaction do
        self.post_confirm_update(  params) 
        return self  
      end
    end
    
    self.quantity    = params[:quantity]       
    self.item_id     = params[:item_id]
           
    self.save 
    
    return self 
  end
  
  
  def post_confirm_update( params)
    # puts "\n\n Inside post_confirm_update\n\n"
    is_item_changed = false
    is_quantity_changed = false 
    
    if params[:item_id] != self.item_id
      is_item_changed = true
      puts "The item is changed"
    end
    
    if params[:item_id] == self.item_id and 
        params[:quantity] != self.quantity 
        puts "The quantity is changed"
      is_quantity_changed = true 
    end
    
    if is_item_changed
      if self.purchase_receival_entries.count != 0 
        self.errors.add(:item_id , "Sudah ada penerimaan barang" )
        return self 
      end
      
      old_item = self.item
      self.item_id = params[:item_id]
      self.quantity = params[:quantity]
      self.save
      return self if self.errors.size != 0 
      
     
      # puts "Gonna update the old item in post confirm update\n"*10
      old_item.update_pending_receival
    end
    
    if is_quantity_changed
      self.quantity = params[:quantity]
      self.save
    end
    
    self.update_fulfillment_status
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
    
    string = "#{header}POE" + 
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
  end
  
  def received_quantity 
    self.purchase_receival_entries.where(:is_confirmed => true, :is_deleted => false ).sum('quantity')
  end
  
  def pending_receival
    self.quantity - self.received_quantity 
  end
  
end