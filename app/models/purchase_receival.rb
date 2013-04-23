class PurchaseReceival < ActiveRecord::Base
  include StockMutationDocument
  # attr_accessible :title, :body
  validates_presence_of :supplier_id  
  has_many :purchase_receival_entries 
  
  belongs_to :supplier 
  
   
   
  def self.active_objects
    self.where(:is_deleted => false ).order("id DESC")
  end
  

  
  def delete_object

    if self.is_confirmed?
      self.is_deleted = true 
      self.save 
      
    else
      self.destroy
    end
    
    self.purchase_receival_entries.each do |entry|
      entry.delete_object 
    end
  end
  
 
  
   
  
  
  def active_purchase_receival_entries 
    self.purchase_receival_entries.where(:is_deleted => false ).order("id DESC")
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
    
    if new_object.save
      new_object.generate_code
    end
    
    return new_object 
  end
  
  def generate_code
    # get the total number of sales receival created in that month 
    
    # total_sales_receival = SalesOrder.where()
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
    
    
    string = "#{header}PRC" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s + '/' + 
              counter.to_s
              
    self.code =  string 
    self.save 
  end
   
  
  def confirm 
    return nil if self.active_purchase_receival_entries.count == 0 
    return nil if self.is_confirmed == true  
    
    # transaction block to confirm all the sales item  + sales receival confirmation 
    ActiveRecord::Base.transaction do
      self.confirmed_at = DateTime.now 
      self.is_confirmed = true 
      self.save 
      self.generate_code
      self.purchase_receival_entries.each do |po_entry|
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
