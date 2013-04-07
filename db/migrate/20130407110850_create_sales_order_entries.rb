class CreateSalesOrderEntries < ActiveRecord::Migration
  def change
    create_table :sales_order_entries do |t|

      t.integer :sales_order_id
      
      t.integer :entry_id 
      t.integer :entry_case , :default => SALES_ORDER_ENTRY_CASE[:item]
      
      t.integer :quantity  # for service, it is 1 by default 
      # the seller has no ability to change price on the fly. If he wants to change price:
      # 1. give specific discount
      # 2. global changes (change the item price)
       
      t.decimal :unit_price , :precision => 11, :scale => 2 , :default => 0
      t.decimal :total_price , :precision  => 11, :scale => 2 , :default => 0  # 10^9 << max value
      t.decimal :discount , :precision           => 4, :scale => 2 , :default => 0  # 99.99 << max value

      t.boolean :is_deleted , :default => false 
      
      t.timestamps
    end
  end
end
