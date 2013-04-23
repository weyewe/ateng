class Customer < ActiveRecord::Base
  include UniqueNonDeleted
  validate :unique_non_deleted_name 
   
  validates_presence_of :name 
 
 
  def self.active_objects
    self.where(:is_deleted => false).order("id DESC")
  end
  
  
  
  def self.create_object( params )
    
    new_object = self.new 
    new_object.name = params[:name]
    new_object.contact_person = params[:contact_person]
    new_object.phone = params[:phone]
    new_object.mobile = params[:mobile]
    new_object.email = params[:email]
    new_object.bbm_pin = params[:bbm_pin]
    new_object.town_id = params[:town_id]
    new_object.office_address = params[:office_address]
    new_object.delivery_address = params[:delivery_address]
    
    new_object.save 
    return new_object 
  end
  
  def update_object( params )
    self.name = params[:name]
    self.contact_person = params[:contact_person]
    self.phone = params[:phone]
    self.mobile = params[:mobile]
    self.email = params[:email]
    self.bbm_pin = params[:bbm_pin]
    self.town_id = params[:town_id]
    self.office_address = params[:office_address]
    self.delivery_address = params[:delivery_address]
    
    self.save 
    return self
  end
  
  def delete_object
    self.is_deleted = true
    self.save 
  end
end
