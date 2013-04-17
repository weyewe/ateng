class ServiceComponent < ActiveRecord::Base
  include UniqueNonDeleted
  validate :unique_non_deleted_name 
  validates_presence_of :name, :service_id 
  # attr_accessible :title, :body
  has_many :service_executions
  has_many :employees, :through => :service_executions 
  
  has_many :material_usages 
  
  belongs_to :service  
  
  
  def self.create_object(params)
    new_object = self.new 
    new_object.name = params[:name]
    new_object.service_id = params[:service_id]
    new_object.commission_amount = BigDecimal( params[:commission_amount] )
    new_object.save
    return new_object
  end
  
  def update_object( params )
    is_commission_amount_changed = ( self.commission_amount != BigDecimal( params[:commission_amount]))? true : false 
    
    # service_id can't be changed  
    
    self.name = params[:name]
    self.commission_amount = BigDecimal( params[:commission_amount])
    if self.save 
      if is_commission_amount_changed
        self.service_executions.where(:is_commission_approved => false, :is_deleted => false).each do |service_execution|
          service_execution.commission_amount = self.commission_amount
          service_execution.save
        end
      end
    end
  end
  
  
  def has_confirmed_sales?
    SalesOrderEntry.where(
      :is_deleted => false, 
      :is_confirmed => true,
      :entry_case => SALES_ORDER_ENTRY_CASE[:service],
      :entry_id => self.id 
    ).length != 0
  end
  
  def has_sub_documents?
    self.material_usages.where(:is_deleted => false).length != 0 or 
    self.service_executions.where(:is_deleted => false ).length != 0 
  end
  
  def delete_object
    if self.has_confirmed_sales? or self.has_sub_documents?
      self.is_deleted = true
      self.save 
    else
      self.destroy 
    end
  end
  
end
