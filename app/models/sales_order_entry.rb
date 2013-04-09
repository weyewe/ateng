class SalesOrderEntry < ActiveRecord::Base
  belongs_to :sales_order 
  has_many :service_executions 
  has_many :material_consumptions 
  
  validate  :quantity_must_greater_than_zero, 
            # :unit_price_must_be_greater_than_zero , # it is commented because we are inferring the unit price from the item
            :item_sales_object_entry_uniqueness ,
            :discount_must_be_between_0_and_100
            
  validates_presence_of :sales_order_id , :entry_id, :entry_case , :discount 
            
  def quantity_must_greater_than_zero
    if not quantity.present? or quantity <= 0 
      errors.add(:quantity , "Quantity harus setidaknya 1" )  
    end
  end
  
  # def unit_price_must_be_greater_than_zero
  #   if not unit_price.present? or unit_price <= BigDecimal('0') 
  #     errors.add(:unit_price , "Harga harus lebih besar dari 0" )  
  #   end
  # end
  
  def item_sales_object_entry_uniqueness
    
    return nil if not self.is_product? 
    item = self.sales_object 
    return nil if item.nil? 
    
    parent = self.sales_order 
    
    # on update, this validation is called before_save 
    # so, when we are searching, it won't be found out. 
    # there is only 1 in the database. with this new shite. it is gonna be 2. 
    
    # but on create, this validation somewhow shows the data. NO.it is our fault
    # in the create action, it calls 2 #CREATE action
    sales_order_entry_count = SalesOrderEntry.where(
      :entry_id => self.entry_id,
      :entry_case => self.entry_case , 
      :sales_order_id => parent.id  
    ).count 
    
    msg = "Item #{item.name}  sudah terdaftar di penerimaan ini"
    
    if not self.persisted? and sales_order_entry_count != 0
      errors.add(:item_id , msg ) 
    elsif self.persisted? and not self.entry_id_changed? and sales_order_entry_count > 1
      errors.add(:item_id , msg ) 
    elsif self.persisted? and self.entry_id_changed? and sales_order_entry_count != 0 
      errors.add(:item_id , msg ) 
    end
  end
  
  def discount_must_be_between_0_and_100
    return nil if not self.discount.present?
    
    if discount < BigDecimal('0') or discount > BigDecimal('100')
      errors.add(:item_id , "Diskon harus diantara 0% - 100%" ) 
    end
  end
  
  def self.create_object(  parent , params ) 
    new_object  = self.new 
    
    new_object.entry_id = params[:entry_id]
    new_object.entry_case = params[:entry_case]
    
    if params[:entry_case] == SALES_ORDER_ENTRY_CASE[:item]
      new_object.quantity = params[:quantity]
    else
      new_object.quantity =  1 
    end
    
    new_object.discount = BigDecimal( params[:discount] )
    new_object.sales_order_id = parent.id 
    
   
    new_object.assign_total_price if new_object.save 
    
    return new_object 
  end
  
  def update_object( params ) 
    # check if it is confirmed 
    
    self.entry_id = params[:entry_id]
    if self.entry_case == SALES_ORDER_ENTRY_CASE[:item]
      self.quantity = params[:quantity]
    end
    
    self.discount = BigDecimal( params[:discount])
   
    
    if self.save 
      self.assign_total_price 
      if self.entry_case == SALES_ORDER_ENTRY_CASE[:service]
        # delete the MaterialUsed and ServicePerformed 
      end
    end
    
    
    return self 
  end
  
  def assign_total_price
    self.unit_price = self.sales_object.selling_price
    self.total_price = ( self.unit_price * self.quantity )*( 1.0 - self.discount )
    self.save 
  end
  
      
  
  def is_product?
    self.entry_case == SALES_ORDER_ENTRY_CASE[:item]
  end
  
  def is_service?
    self.entry_case == SALES_ORDER_ENTRY_CASE[:service]
  end
  
  def sales_object
    if self.is_product?
      return Item.find_by_id self.entry_id
    else self.is_service?
      return Service.find_by_id self.entry_id
    end
  end
  
  def confirm
    return nil if self.is_confirmed? 
    
    if self.is_product?  # optimized for retail : auto deduct
      self.deduct_stock 
    elsif self.is_service? 
      self.confirm_service_performed_and_deduct_stock 
      # ServicePerformed => commission to the employee responsible 
      # MaterialUsage => basis of stock deduction 
    end
    
    self.is_confirmed = true 
    self.confirmed_at = DateTime.now 
    self.save 
  end
  
  def deduct_stock
    # what if there is no stock? => no deduction
    
    # start with stock mutation, then , the stock mutation will distribute the deduction

  end
   
  def confirm_service_performed_and_deduct_stock
    self.material_consumptions.each do |material_consumption|
      material_consumption.confirm 
    end
    
    self.service_executions.each do |service_execution|
      service_execution.confirm 
    end
  end
  
  def delete
    if not self.is_confirmed?
      self.destroy 
    end
    # if it is service => problematic. we have to 
    # delete the MaterialUsed and ServicePerformed  
  end
     
       
end
