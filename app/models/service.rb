
# store the info of service name , description, last price
# linked to the service_price_history 
# linked_to employee doing the service
class Service < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :service_components  # this is the template (formulation). 
  
  # the object being instantiated : sales_order_entry -> can refer to the item or to the service
  # if it is the service, it will NOT auto instantiate the  service component instance 
  # must be added manually 
  
  
  def self.create(  params ) 
    
    new_object               = self.new  
    
    new_object.name          = params[:name] 
    new_object.selling_price = params[:selling_price]


    new_object.save 
    
    # give callback to update the price history. that this is using the last pricing history 
    # not important for now, but in the long run, we will need that shite. 
    return new_object 
  end
  
  def  update(  params )  
    self.name          = params[:name] 
    self.selling_price = params[:selling_price] 

    self.save 
    return self 
  end
  
  def delete
    self.is_deleted = true 
    self.save
  end
  
  
  
end
