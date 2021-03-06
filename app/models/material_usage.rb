class MaterialUsage < ActiveRecord::Base
  include UniqueNonDeleted
  validate :unique_non_deleted_name 
  
  def has_duplicate_entry?
    
    current_object=  self  
    self.class.find(:all, :conditions => ['lower(name) = :name and is_deleted = :is_deleted ' + 
                   ' and service_component_id = :service_component_id', 
                {:name => current_object.name.downcase, :is_deleted => false ,
                  :service_component_id => current_object.service_component_id }]).count != 0  
  end
  
  def duplicate_entries
    current_object=  self  
    return self.class.find(:all, :conditions => ['lower(name) = :name and is_deleted = :is_deleted  '+ 
                   ' and service_component_id = :service_component_id', 
                {:name => current_object.name.downcase, :is_deleted => false ,
                  :service_component_id => current_object.service_component_id  }]) 
  end
  
  has_many :items, :through => :usage_options
  has_many :usage_options 
  
  belongs_to :service_component 
  has_many :material_consumptions 
  
  belongs_to :service
  
  validates_presence_of :service_component_id, :name # , :service_id  
  validate :service_component_must_not_be_deleted
  
  def service_component_must_not_be_deleted
    if not self.service_component_id.nil? and self.service_component.is_deleted? 
      errors.add(:service_component_id , "Service Component harus aktif" )  
    end
  end
  
  
  def active_usage_options
    self.usage_options.order("id DESC")
  end
  
  def self.create_object( params ) 
    new_object = self.new
    new_object.name = params[:name]
    new_object.service_component_id = params[:service_component_id]
    
    if new_object.save 
      new_object.service_id =  new_object.service_component.service_id 
      new_object.save 
    end
    
    return new_object
  end
  
  def update_object( params ) 
    is_service_component_changed = (self.service_component_id != params[:service_component_id])? true : false 
    self.name = params[:name]
    self.service_component_id = params[:service_component_id] 
    
    if is_service_component_changed and self.service.has_sales?
      self.errors.add(:service_component_id, "Sudah ada penjualan")
    end
    
    return self if self.errors.size != 0 
    
    self.save 
    
    return self
  end
  
  def has_sub_documents?
    self.usage_options.length != 0  
  end
  
  def delete_object 
    
    if self.service.has_sales?    
      self.errors.add(:generic_errors, "Sudah ada penjualan dengan service ini")
      return self 
    elsif self.has_sub_documents? 
      self.errors.add(:generic_errors, "Untuk menghapus, hapus dahulu pilihan material")
      return self
    else
      self.destroy 
    end
  end
  
  def first_available_option
    return nil if self.usage_options.length == 0 
    
    mu_id = self.id 
    UsageOption.joins(:item).where{
      (quantity.lte item.ready ) & 
      ( material_usage_id.eq  mu_id)
    }.order("id ASC").first 
  end
end
