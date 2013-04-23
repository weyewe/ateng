class PurchaseOrder < ActiveRecord::Base
  # attr_accessible :title, :body
  validates_presence_of :supplier_id  
  has_many :purchase_order_entries 
  
  belongs_to :supplier 
  
  validate :valid_supplier
  
  def valid_supplier
    if self.supplier.nil?
      errors.add(:supplier_id, "Harus diisi")
    end
  end
   
   
  def self.active_objects
    self.where(:is_deleted => false ).order("created_at DESC")
  end
  
  def delete_object
    if self.is_confirmed? 
      ActiveRecord::Base.transaction do
        self.post_confirm_delete
      end
      return self
    end
   
    self.destroy
  end
  
  def post_confirm_delete 
    
    purchase_order_entry_id_list = self.purchase_order_entries.map{|x| x.id }
    if PurchaseReceivalEntry.where(:purchase_order_entry_id => purchase_order_entry_id_list).count != 0 
      self.errors.add(:generic_errors , "Sudah ada penerimaan." )  
      return self
    end
    
    
     
    self.purchase_order_entries.each do |poe|
      poe.delete 
    end 
    
    self.is_deleted = true 
    self.save 
  end
  
   
  
  
  def active_purchase_order_entries 
    self.purchase_order_entries.where(:is_deleted => false )
  end
  
  def update_object(  params ) 
    if self.is_confirmed?
      return self
    end
    self.supplier_id = params[:supplier_id]
    self.save
    return self 
  end
  
  
=begin
  BASIC
=end
  def self.create_object(   params ) 
    
    new_object = self.new
    new_object.supplier_id = params[:supplier_id]
    
    # today_date_time = DateTime.now 
    # 
    # new_object.order_date   = 
    
    if new_object.save
      new_object.generate_code
    end
    
    return new_object 
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
    
    
    string = "#{header}PO" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s + '/' + 
              counter.to_s
              
    self.code =  string 
    self.save 
  end
   
  
  def confirm 
    return nil if self.active_purchase_order_entries.count == 0 
    return nil if self.is_confirmed == true  
    
    # transaction block to confirm all the sales item  + sales order confirmation 
    ActiveRecord::Base.transaction do
      self.confirmed_at = DateTime.now 
      self.is_confirmed = true 
      self.save 
      self.generate_code
      self.purchase_order_entries.each do |po_entry|
        po_entry.confirm 
      end
    end 
  end
  
  
  
=begin
  Sales Invoice Printing
=end
  def printed_sales_invoice_code
    self.code.gsub('/','-')
  end

  def calculated_vat
    BigDecimal("0")
  end

  def calculated_delivery_charges
    BigDecimal("0")
  end

  def calculated_sales_tax
    BigDecimal('0')
  end
end
