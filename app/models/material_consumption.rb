class MaterialConsumption < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_order_entry 
  belongs_to :material_usage 
  belongs_to :usage_option 
  
  def confirm
  end
end
