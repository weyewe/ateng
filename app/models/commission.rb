class Commission < ActiveRecord::Base
  belongs_to :commissionable , :polymorphic => true 
  belongs_to :employee 
  
  validates_presence_of :employee_id
  
  
  def update_commission_amount
    if self.commissionable.class.to_s  == "ServiceExecution"
      self.commission_amount = self.commissionable.commission_amount
    else
      self.commission_amount = self.commissionable.sellable.commission_amount 
    end 
    
    self.save 
  end
  
  def self.create_object( commissionable, params )
    new_object                = self.new 
    new_object.commissionable = commissionable 
    new_object.employee_id    = params[:employee_id]
    
    if new_object.save
      new_object.update_commission_amount
    end
    
    return new_object 
  end
  
  def update_object( commissionable, params)
    self.commissionable = commissionable 
    self.employee_id = params[:employee_id]
    if self.save
      self.update_commission_amount
    end
    return self 
  end
  
  
  def delete_object
    self.destroy
    # employee.update_unpaid_commissions
  end
end
