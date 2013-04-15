class SalesOrderEntry < ActiveRecord::Base
  belongs_to :sales_order 
  has_many :service_executions 
  has_many :material_consumptions 
  
  has_many :sales_return_entries 
  
  validate  :quantity_must_greater_than_zero, 
            :item_sales_object_entry_uniqueness ,
            :discount_must_be_between_0_and_100,
            
            :post_confirm_update_constraint
            
  validates_presence_of :sales_order_id , :entry_id, :entry_case , :discount 
            
  def quantity_must_greater_than_zero
    if not quantity.present? or quantity <= 0 
      errors.add(:quantity , "Quantity harus setidaknya 1" )  
    end
  end
  
  
  def item_sales_object_entry_uniqueness
    
    return nil if not self.is_product? 
    item = self.sales_object 
    return nil if item.nil? 
    
    parent = self.sales_order 
    
   
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
  
  def post_confirm_update_constraint
    return nil if not self.is_confirmed? 
    return nil if self.is_deleted? 
    # puts "********************** Gonna Execute post confirm \n"*10
    # if self.sales_return_entries.count != 0  and self.entry_case == SALES_ORDER_ENTRY_CASE[:item]
    #   
    #   # watch the stock_mutation 
    #   
    #   
    #   
    #   # if there is sales return, watch the max quantity 
    #   total_returned = self.sales_return_entries.sum("quantity")
    #   
    #   if quantity < total_returned 
    #     errors.add(:quantity , "Ada sales return dengan jumlah: #{total_returned}" ) 
    #   end
    # end
    
    if self.entry_case == SALES_ORDER_ENTRY_CASE[:item]
      stock_mutation = StockMutation.where(
        :source_document_entry => self.class.to_s,
        :source_document_entry_id => self.id 
      ).first
      
      item = stock_mutation.item 
      current_quantity_usage  = stock_mutation.quantity 
      actual_item_ready = item.ready + current_quantity_usage 
     
      
      if actual_item_ready - quantity < 0 
        errors.add(:quantity , "Kuantitas maksimum: #{actual_item_ready}" ) 
      end
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
    # if self.is_confirmed?
    #   self.validate_post_confirm_update 
    #   return self if self.errors.size != 0 
    # end
    
    self.entry_id = params[:entry_id]
    if self.entry_case == SALES_ORDER_ENTRY_CASE[:item]
      self.quantity = params[:quantity]
      # quantity for service, by default == 1 
    end
    
    self.discount = BigDecimal( params[:discount])
    
    ActiveRecord::Base.transaction do
      if self.save 
        # puts "update object => going to StockMutation.create_or_update_sales_stock_mutation"
        StockMutation.create_or_update_sales_stock_mutation( self ) if self.is_confirmed?
        self.assign_total_price 
        if self.entry_case == SALES_ORDER_ENTRY_CASE[:service]
          # delete the MaterialUsed and ServicePerformed 
        end
      end
    end
    
    
    return self 
  end
  
  def validate_post_confirm_update
    
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
    
    ActiveRecord::Base.transaction do
      if self.is_product?  # for POS: auto deduct 
        StockMutation.create_or_update_sales_stock_mutation( self ) 
      elsif self.is_service? 
        self.confirm_service_performed_and_deduct_stock 
        # ServicePerformed => commission to the employee responsible 
        # MaterialUsage => basis of stock deduction 
      end

      self.is_confirmed = true 
      self.confirmed_at = DateTime.now 
      self.save
    end
    
  end
  
   
  def confirm_service_performed_and_deduct_stock
    self.material_consumptions.each do |material_consumption|
      material_consumption.confirm 
    end
    
    self.service_executions.each do |service_execution|
      service_execution.confirm 
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
      
      if self.is_product?  # for POS: auto deduct 
        StockMutation.delete_object( self ) 
      elsif self.is_service? 
        self.confirm_service_performed_and_deduct_stock 
        # ServicePerformed => commission to the employee responsible 
        # MaterialUsage => basis of stock deduction 
      end

      
    end
    
    
    # if it is service => problematic. we have to 
    # delete the MaterialUsed and ServicePerformed  
  end
     
       
end
