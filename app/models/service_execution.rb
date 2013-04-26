# this is working on the sales level... not master data creation 
class ServiceExecution < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :service_component
  belongs_to :employee 
  belongs_to :sales_order_entry 
  has_many :material_consumptions 
  
  validates_presence_of :service_component_id,  :sales_order_entry_id
  # after_save :update_commission_amount , :update_employee_outstanding_commission_payment 
  
  # validate :employee_must_not_deleted
  validate :service_component_must_not_be_deleted 
  validate :entry_uniqueness 
  
  
  has_one :commission, :as => :commissionable 
  
  # def employee_must_not_deleted
  #   if not self.is_confirmed? and self.employee.is_deleted?
  #     errors.add(:employee_id , "Karyawan harus aktif" )  
  #   end
  # end
  
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
      :sales_order_entry_id  => parent.id ,
      :is_deleted => false 
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
  
  def create_material_consumptions
    self.service_component.active_material_usages.each do |material_usage|
      usage_option = material_usage.first_available_option
      next if usage_option.nil? 

      material_consumption = MaterialConsumption.create_object({
        :service_execution_id => self.id ,
        :usage_option_id => usage_option.id ,
        :sales_order_entry_id => self.sales_order_entry.id,
        :material_usage_id => material_usage.id 
      })
      
      if self.sales_order_entry.is_confirmed?
        material_consumption.confirm
      end
      
   
    end
  end
  
  def delete_material_consumptions
    self.material_consumptions.each do |material_consumption|
      material_consumption.delete_object 
    end
  end
  
  def self.create_object(params)
    new_object = self.new 
    new_object.employee_id = params[:employee_id]
    new_object.service_component_id = params[:service_component_id]
    new_object.sales_order_entry_id = params[:sales_order_entry_id]
    if new_object.save
      
      new_object.create_material_consumptions
       
      if new_object.errors.size == 0 and new_object.sales_order_entry.is_confirmed?
        new_object.confirm
      end
    end
    return new_object 
  end
  
  
  
  def update_object( params ) 
    is_employee_id_changed = false 
    
    if self.employee_id != params[:employee_id]
      is_employee_id_changed = true 
      self.employee_id = params[:employee_id]
    end
    
    
    
    is_service_component_id_changed = false 
    
    if self.service_component_id != params[:service_component_id]
      self.service_component_id = params[:service_component_id]
      is_service_component_id_changed = true 
    end
    
    if self.save
      
      self.commission.delete_object if not self.commission.nil? and self.employee_id.nil? 
      
      if not self.employee_id.nil? and ( is_employee_id_changed or is_service_component_id_changed )
        
        puts "YEAH baby, the sales_order_entry is confirmed" if  self.sales_order_entry.is_confirmed? 
        self.create_commission if self.sales_order_entry.is_confirmed? 
        
        if is_service_component_id_changed
          # update material consumption 
          self.delete_material_consumptions
          self.create_material_consumptions
        end
      end
    end
    
    return self
  end
  
  def confirm
    return nil if self.is_confirmed?
    
    self.is_confirmed = true 
    self.save 
    self.update_commission_amount
    self.create_commission
  end
  
  def create_commission
    
    if not self.employee_id.nil? 
      Commission.create_or_update_object( self, {
        :employee_id => self.employee_id 
      } )
    end
  end
  
  
  def delete_object 
    ActiveRecord::Base.transaction do
      self.delete_material_consumptions
      
      self.commission.delete_object if not self.commission.nil? 
      
      if not self.is_confirmed?
        self.destroy 
      else
        self.is_deleted = true 
        self.save 
      end
    end
     
    return self 
  end
  
  def active_material_consumptions
    self.material_consumptions.where(:is_deleted => false ).order("id DESC")
  end
  
  
end
