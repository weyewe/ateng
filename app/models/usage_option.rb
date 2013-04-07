class UsageOption < ActiveRecord::Base
  belongs_to :material_usage 
  belongs_to :item 
end
