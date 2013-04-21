# store the info of service name , description, last price
# linked to the service_price_history 
# linked_to employee doing the service
class Service < ActiveRecord::Base
  include UniqueNonDeleted
  validate :unique_non_deleted_name 
  validates_presence_of :name
  has_many :service_components  # this is the template (formulation). 
  
  has_many :sales_order_entries, :as => :sellable 
  
  
  validate :selling_price_must_not_less_or_equal_than_zero 
  
  def selling_price_must_not_less_or_equal_than_zero
    if not selling_price.present? or selling_price <= BigDecimal('0')
      errors.add(:selling_price , "Harga jual harus lebih besar dari 0 rupiah" )  
    end
  end

  
  
  def active_service_components
    self.service_components.where(:is_deleted => false ).order("id DESC")
  end
  
  def self.active_objects
    self.where(:is_deleted => false ).order("id DESC")
  end
  
  def self.create_object(  params ) 
    
    new_object               = self.new  
    
    new_object.name          = params[:name] 
    new_object.selling_price = params[:selling_price]


    new_object.save 
    
    # give callback to update the price history. that this is using the last pricing history 
    # not important for now, but in the long run, we will need that shite. 
    return new_object 
  end
  
  def  update_object(  params )  
    is_selling_price_changed = ( self.selling_price != BigDecimal(params[:selling_price]))? true : false 
    self.name          = params[:name] 
    self.selling_price = params[:selling_price] 
    
    if self.save 
      if is_selling_price_changed
        # update all commission in service execution 
      end
    end
    return self 
  end
  
  def has_sales?
    SalesOrderEntry.where(
      :entry_id => self.id, 
      :entry_case => SALES_ORDER_ENTRY_CASE[:service]
    ).length != 0
  end
  
  def delete_object
    if self.has_sales? 
      self.is_deleted = true 
      self.save
    else
      self.destroy 
    end
  end
  
  
  
end
