class ServiceExecution < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :service_component
  belongs_to :employee 
  
  def confirm
    
  end
end
