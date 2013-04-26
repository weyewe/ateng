class Employee < ActiveRecord::Base
  include UniqueNonDeleted
  attr_accessible :name, :phone, :mobile , 
                  :email, :bbm_pin, :address 
  
  validates_presence_of :name 
  validate :unique_non_deleted_name

 
 
  has_many :service_executions 
  has_many :service_components, :through => :service_executions 
  
  has_many :commissions 
  
  def self.active_objects
    self.where(:is_deleted => false ).order("id DESC")
  end
  
  def self.create_object( params )
    
    new_object         = self.new 
    new_object.name    = params[:name]
    new_object.phone   = params[:phone]
    new_object.mobile  = params[:mobile]
    new_object.email   = params[:email]
    new_object.bbm_pin = params[:bbm_pin]

    new_object.save 
    return new_object 
  end
  
  def update_object( params )
    self.name    = params[:name]
    self.phone   = params[:phone]
    self.mobile  = params[:mobile]
    self.email   = params[:email]
    self.bbm_pin = params[:bbm_pin]
    self.town_id = params[:address]
    
    self.save 
    return self
  end
  
  def delete_object 
    self.is_deleted = true 
    self.save 
  end
end
