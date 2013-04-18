# this is working on the sales level... not master data creation 
class ServiceExecution < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :service_component
  belongs_to :employee 
  
  validates_presence_of :service_component_id, :employee_id 
  after_save :update_commission_amount , :update_employee_outstanding_commission_payment 
  
  validate :employee_must_not_deleted
  validate :service_component_must_not_be_deleted 
  
  
  has_one :commissions, :as => :commissionable 
  
  def employee_must_not_deleted
    if not self.is_confirmed? and self.employee.is_deleted?
      errors.add(:employee_id , "Karyawan harus aktif" )  
    end
  end
  
  def service_component_must_not_be_deleted
    if not self.is_confirmed? and self.service_component.is_deleted?
      errors.add(:employee_id , "Service Component harus aktif" )  
    end
  end
  
  def update_commission_amount
    self.commission_amount = self.service_component.commission_amount
    self.service_id = self.service_component.service_id 
    self.save
  end
  
  def update_employee_outstanding_commission_payment
    if self.is_confirmed?
      # employee.update_outstanding_commission_payment
    end
  end
  
  def self.create_object(params)
    new_object = self.new 
    new_object.employee_id = params[:employee_id]
    new_object.service_component_id = params[:service_component_id]
    new_object.save
    return new_object 
  end
  
  def update_object( params ) 
    self.employee_id = params[:employee_id]
    self.service_component_id = params[:service_component_id]
    self.save
    return self
  end
  
  def confirm
    return nil if self.is_confirmed?
    
    self.is_confirmed = true 
    self.save 
  end
  
  def delete_object 
    if not self.is_confirmed?
      self.destroy 
      return 
    else
      self.is_deleted = true 
      self.save 
      return self
    end
  end
  
  
end
