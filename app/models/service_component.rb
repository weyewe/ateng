class ServiceComponent < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :service_executions
  has_many :employees, :through => :service_executions 
  
  belongs_to :service  
end
