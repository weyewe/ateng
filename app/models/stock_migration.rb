class StockMigration < ActiveRecord::Base
  include StockMutationDocument
  include StockMutationDocumentEntry 
  include StockEntryDocument
  include StockEntryDocumentEntry
  # attr_accessible :title, :body
  belongs_to :item
  validates_presence_of :quantity , :item_id
  validate :quantity_not_zero
  validate :price_not_less_than_zero 
  validate :only_one_stock_migration_per_item
  
  def self.active_objects
    self.order("id DESC") 
  end
  
  def quantity_not_zero
    if quantity.present? and quantity <=   0   
      errors.add(:quantity , "Tidak lebih kecil dari 0" )  
    end
  end
  
  def price_not_less_than_zero
    zero_value = BigDecimal('0')
    if average_cost <= zero_value 
      errors.add(:average_cost , "Harga tidak boleh kurang dari 0" ) 
    end
  end
  
  def only_one_stock_migration_per_item
    if self.persisted? and   
        StockMigration.where(:item_id => self.item_id).count != 1 
      errors.add(:item_id , "Tidak boleh ada stock migration ganda" )  
    end
  end
  
  def generate_code
    # get the total number of sales order created in that month 
    
    # total_sales_order = SalesOrder.where()
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
    
    
    string = "#{header}SMG" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s + '/' + 
              counter.to_s
              
    self.code =  string 
    self.save 
  end
  
  
  # auto confirm the stock migration 
  def self.create_object( params )
    new_object              = StockMigration.new 
    if params[:item_id].present?  and StockMigration.where(:item_id => params[:item_id]).count != 0 
      new_object.errors.add(:quantity , "Tidak boleh ada stock migration ganda" )  
      return new_object
    end
    
    new_object.item_id      = params[:item_id]
    new_object.quantity     = params[:quantity]
    new_object.average_cost = BigDecimal( params[:average_cost] )
    ActiveRecord::Base.transaction do
      if new_object.save  
        new_object.generate_code
        new_object.confirm 
      end 
    end
    
    return new_object 
  end
  
  def  update_object(  params )
    self.quantity     = params [:quantity]
    self.average_cost = BigDecimal( params[:average_cost] ) 
    
    ActiveRecord::Base.transaction do
      if self.save   and self.is_confirmed? and not  stock_entry.nil?
        StockMutation.create_or_update_stock_migration_stock_mutation( self ) 
        # stock_entry.update_from_document_entry( self, self.quantity, self.average_cost )  
      end
    end
    
    return self 
  end
  
  def stock_entry
    StockEntry.where(
      :source_document_entry_id => self.id ,
      :source_document_entry => self.class.to_s
    ).first 
  end
  
  
  
  def confirm 
    return nil if self.is_confirmed?   
    # transaction block to confirm all the sales item  + sales order confirmation 
    ActiveRecord::Base.transaction do
      self.confirmed_at = DateTime.now 
      self.is_confirmed = true 
      self.save 
      self.generate_code
       
      StockMutation.create_or_update_stock_migration_stock_mutation( self ) 
    end
  end
  
  
  def parent_document
    self 
  end
  
    
  
  
end
