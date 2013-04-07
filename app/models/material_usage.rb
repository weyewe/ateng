class MaterialUsage < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :items, :through => :usage_options
  has_many :usage_options 
end
