class StockEntryMutation < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :stock_entry
  belongs_to :stock_mutation 
end
