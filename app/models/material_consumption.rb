class MaterialConsumption < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_order_entry 
  belongs_to :material_usage 
  belongs_to :usage_option 
  
  validate :entry_uniqueness 
  
  def entry_uniqueness
    # from a given material usage, there can only be one material consumption 
  end
  
  def create( params ) 
    new_object = self.new 
    new_object.service_component_id = params[:service_component_id]
    new_object.usage_option_id = params[:usage_option_id]
    new_object.save 
  end
  
  def update(params)
  end
  
  def confirm
    # deduct stock (stock mutation) 
  end
  
  def delete
  end
  
  

  
end
