class MaterialConsumption < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_order_entry 
  # belongs_to :material_usage 
  belongs_to :usage_option 
  
  validate :entry_uniqueness 
  validate :item_ready_availability 
  
  def item_ready_availability
    return nil if self.usage_option_id.nil? 
    new_usage_option = self.usage_option 
    new_item = new_usage_option.item 
    
    if new_item.ready <  new_usage_option.quantity 
      errors.add(:usage_option_id, "Kuantitas bahan baku #{new_item.name} tidak memadai")
    end
  end
  
  def entry_uniqueness
    # from a given material usage, there can only be one material consumption 
  end
  
  def self.create_object( params ) 
    new_object = self.new 
    new_object.service_component_id = params[:service_component_id]
    new_object.usage_option_id = params[:usage_option_id]
    new_object.sales_order_entry_id = params[:sales_order_entry_id]
    new_object.save 
    
    if new_object.errors.size == 0 and new_object.sales_order_entry.is_confirmed? 
      new_object.confirm 
    end
    
    return new_object
  end
  
  def update_object(params)
    is_usage_option_id_changed = ( self.usage_option_id != params[:usage_option_id])? true : false 
    
    self.usage_option_id = params[:usage_option_id]
    
    if self.save 
      StockMutation.create_or_update_service_sales_stock_mutation( self )  if self.is_confirmed? 
    end
    
    return self 
  end
  
  def confirm
    return nil if self.is_confirmed? 
    self.is_confirmed = true
    self.save
    StockMutation.create_or_update_service_sales_stock_mutation( self ) 
  end
  
  def delete_object
    StockMutation.delete_object( self ) 
    self.destroy 
  end
  
  

  
end
