class SalesOrderEntry < ActiveRecord::Base
  belongs_to :sales_order 
  has_many :service_executions 
  has_many :material_consumptions 
  belongs_to :employee 
  
  
  has_many :sales_return_entries # only for product 
  has_one :commission, :as => :commissionable 
  
  belongs_to :sellable , :polymorphic => true 
  
  
  validate  :quantity_must_greater_than_zero, 
            :item_sales_object_entry_uniqueness ,
            :discount_must_be_between_0_and_100,
            :employee_id_presence_on_item_sales , 
            
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
  
  def employee_id_presence_on_item_sales
    if self.entry_case == SALES_ORDER_ENTRY_CASE[:item] and self.employee.nil? 
      errors.add(:employee_id , "Harus memilih karyawan penjual" ) 
    end
  end
  
  def post_confirm_update_constraint
    return nil if not self.is_confirmed? 
    return nil if self.is_deleted? 

    
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
  
  def create_service_sub_documents
    self.sellable.service_components.each do |service_component|
      service_component.material_usages.each do |material_usage|
        first_available_option = material_usage.first_available_option
        
        if first_available_option
           material_consumption = MaterialConsumption.create_object({
             :service_component_id => service_component.id ,
             :usage_option_id => first_available_option.id,
             :sales_order_entry_id => self.id  
           })
        end
        
      end
    end
  end
  
  
  def delete_service_sub_documents
    self.material_consumptions.each do |material_consumption|
      material_consumption.delete_object
    end
    
    self.service_executions.each do |service_execution|
      service_execution.delete_object 
    end
  end
  
  def create_or_update_sales_commissions
    if self.is_product?
      Commission.create_or_update_object( self, {
        :employee_id => self.employee_id 
      })
    elsif self.is_service?
      self.service_executions.each do |service_execution|
        Commission.create_or_update_object( service_execution, {
          :employee_id => self.employee_id 
        })
      end
    end
    
  end
  
  
  def assign_total_price
    self.unit_price = self.sales_object.selling_price
    self.total_price = ( self.unit_price * self.quantity )*( 1.0 - self.discount/100.0 )
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
  
  def self.create_object(  parent , params ) 
    new_object  = self.new 
    
    new_object.entry_id = params[:entry_id]
    new_object.entry_case = params[:entry_case]
    
    if params[:entry_case] == SALES_ORDER_ENTRY_CASE[:item]
      item = Item.find_by_id params[:entry_id]
      new_object.quantity = params[:quantity]
      new_object.sellable = item 
    else
      service = Service.find_by_id params[:entry_id]
      new_object.quantity =  1 
      new_object.sellable = service 
    end
    
    new_object.discount = BigDecimal( params[:discount] )
    new_object.sales_order_id = parent.id 
    new_object.employee_id = params[:employee_id]
   
    
    if new_object.save 
      new_object.assign_total_price 
      if new_object.entry_case == SALES_ORDER_ENTRY_CASE[:service]
        new_object.create_service_sub_documents
      end
      
      # auto confirm. dangerous 
      if new_object.sales_order.is_confirmed?
        new_object.confirm 
      end
    end
    
    return new_object 
  end
  
  
  
  def update_object( params ) 
    
    is_entry_changed = ( self.entry_id != params[:entry_id])? true : false 
    
    self.entry_id = params[:entry_id]
    if self.entry_case == SALES_ORDER_ENTRY_CASE[:item]
      item =  Item.find_by_id params[:entry_id]
      self.quantity = params[:quantity]
      self.sellable = item 
      # quantity for service, by default == 1 
    else
      service = Service.find_by_id params[:entry_id]
      self.quantity =  1 
      self.sellable = service
    end
    
    self.discount = BigDecimal( params[:discount])
    self.employee_id = params[:employee_id]
    
    ActiveRecord::Base.transaction do
      if self.save 
        
        if self.is_product?  # for POS: auto deduct 
          StockMutation.create_or_update_sales_stock_mutation( self ) if self.is_confirmed?
          self.create_or_update_sales_commissions if self.is_confirmed? 
        elsif self.is_service? 
          if is_entry_changed
            self.delete_service_sub_documents
            self.create_service_sub_documents
          end
        end
        
        
        self.assign_total_price 
      end
    end
    
    
    return self 
  end
  
  
  
  
  
  
  
  def confirm
    return nil if self.is_confirmed? 
    
    ActiveRecord::Base.transaction do
      
      if self.is_product?  # for POS: auto deduct 
        StockMutation.create_or_update_sales_stock_mutation( self ) 
        # update commissions 
      elsif self.is_service? 
        self.confirm_service_performed_and_deduct_stock 
      end
      self.is_confirmed = true 
      self.confirmed_at = DateTime.now 
      self.save
      
      
      self.create_or_update_sales_commissions
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
        self.commission.delete_object 
      elsif self.is_service? 
        self.delete_service_sub_documents
      end
    end
    
    
    # if it is service => problematic. we have to 
    # delete the MaterialUsed and ServicePerformed  
  end
  
  
  
     
       
end
