# this is working on the sales level... not master data creation 
class ServiceExecution < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :service_component
  belongs_to :employee 
  belongs_to :sales_order_entry 
  
  validates_presence_of :service_component_id, :employee_id , :sales_order_entry_id
  # after_save :update_commission_amount , :update_employee_outstanding_commission_payment 
  
  validate :employee_must_not_deleted
  validate :service_component_must_not_be_deleted 
  validate :entry_uniqueness 
  
  
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
  
  def entry_uniqueness
    return if self.service_component.nil? 
    return if self.sales_order_entry.nil? 
    
    parent = self.sales_order_entry  
    
   
    service_execution_count = ServiceExecution.where(
      :service_component_id => self.service_component_id,
      :sales_order_entry_id  => parent.id  
    ).count 
    
    service_component = self.service_component
    msg = "Pengerjaan service #{service_component.name} sudah terdaftar"
    
    if not self.persisted? and service_execution_count != 0
      errors.add(:service_component_id , msg ) 
    elsif self.persisted? and not self.service_component_id_changed? and service_execution_count > 1
      errors.add(:service_component_id , msg ) 
    elsif self.persisted? and self.service_component_id_changed? and service_execution_count != 0 
      errors.add(:service_component_id , msg ) 
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
    new_object.sales_order_entry_id = params[:sales_order_entry_id]
    if new_object.save
      if new_object.errors.size == 0 and new_object.sales_order_entry.is_confirmed?
        new_object.is_confirmed = true 
        new_object.update_commission_amount
        new_object.create_commissionable
      end
    end
    return new_object 
  end
  
  def update_object( params ) 
    self.employee_id = params[:employee_id]
    
    # in the validation, we want to check self.is_service_component_id_changed? 
    if self.service_component_id != params[:service_component_id]
      self.service_component_id = params[:service_component_id]
    end
    
    self.save
    return self
  end
  
  def confirm
    return nil if self.is_confirmed?
    
    self.is_confirmed = true 
    self.save 
    self.update_commission_amount
    self.create_commissionable
  end
  
  def create_commissionable
    Commission.create_object( self, {
      :employee_id => self.employee_id 
    } )
  end
  
  def delete_object 
    if not self.is_confirmed?
      self.commission.delete_object
      self.destroy 
      
      return 
    else
      self.is_deleted = true 
      self.save 
      self.commission.delete_object
      return self
    end
  end
  
  
end
