class UsageOption < ActiveRecord::Base
  belongs_to :material_usage 
  belongs_to :item 
  
  def self.create_object( params ) 
  end
  
  def update_object( params ) 
  end
end
