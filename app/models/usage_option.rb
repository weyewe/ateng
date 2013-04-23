class UsageOption < ActiveRecord::Base
  belongs_to :material_usage 
  belongs_to :item 
  belongs_to :service_component
  validates_presence_of :material_usage_id, :item_id, :quantity 
  
  validate :item_is_not_deleted,
            # :service_component_is_not_deleted, 
            :material_usage_is_not_deleted, 
            :quantity_is_more_than_zero 
  
  def item_is_not_deleted
    if  self.item_id.present? and self.item.is_deleted == true 
      self.errors.add(:item_id , "Item #{self.item.name} sudah tidak aktif. Pilih item yang aktif");
    end
  end
  
  # def service_component_is_not_deleted
  #   if  self.service_component_id.present? and self.service_component.is_deleted == true 
  #     self.errors.add(:service_component_id , "Service Component #{self.service_component.name} sudah tidak aktif." + 
  #                                             " Pilih service_component yang aktif");
  #   end
  # end
  
  def material_usage_is_not_deleted
    if  self.material_usage_id.present? and self.material_usage.is_deleted == true 
      self.errors.add(:material_usage_id , "Penggunaan Material #{self.material_usage.name} sudah tidak aktif."+ 
                                          " Pilih penggunaan material yang aktif");
    end
  end
  
  def quantity_is_more_than_zero
    if self.quantity.present? and self.quantity <= 0 
      self.errors.add(:quantity, "Quantity tidak boleh lebih kecil dari 1")
    end
  end
   
  
  def self.create_object( params ) 
    new_object = self.new 
    # new_object.service_component_id = params[:service_component_id]
    new_object.material_usage_id    = params[:material_usage_id]
    new_object.item_id              = params[:item_id]
    new_object.quantity             = params[:quantity]

    if new_object.save
      service_component = new_object.material_usage.service_component 
      new_object.service_component_id = service_component.id
      new_object.save 
    end
    
    return new_object 
  end
  
  def update_object( params ) 
    is_item_changed           = ( self.item_id != params[:item_id])? true : false 
    is_quantity_changed       = (self.quantity != params[:quantity])? true : false 
    is_material_usage_changed = (self.material_usage_id != params[:material_usage_id])? true : false 
    
    self.material_usage_id = params[:material_usage_id]
    self.item_id = params[:item_id]
    self.quantity = params[:quantity]
    
    service = self.material_usage.service 
    
    has_sales_error_message = "Sudah ada penjualan"
    if is_item_changed and service.has_sales?
      self.errors.add(:item_id, has_sales_error_message)
    end
    
    if is_quantity_changed and service.has_sales?
      self.errors.add(:quantity, has_sales_error_message)
    end
    
    if is_material_usage_changed and service.has_sales?
      self.errors.add(:material_usage_id, has_sales_error_message)
    end
    
    return self if self.errors.size != 0 
    
    self.save 
    return self 
  end
  
  def delete_object 
    if self.material_usage.service.has_sales?    
      self.errors.add(:generic_errors, "Sudah ada penjualan dengan service dari pilihan ini")
      return self 
    else
      self.destroy 
    end
  end
  
  def details
    "#{self.item.name} x #{self.quantity}"
  end
end
