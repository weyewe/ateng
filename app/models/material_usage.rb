class MaterialUsage < ActiveRecord::Base
  include UniqueNonDeleted
  validate :unique_non_deleted_name 
  validates_presence_of :name, :service_id
  
  has_many :items, :through => :usage_options
  has_many :usage_options 
  
  belongs_to :service_component 
  
  def self.create_object( params ) 
  end
  
  def update_object( params ) 
  end
end
