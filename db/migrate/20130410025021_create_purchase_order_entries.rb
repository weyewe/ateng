class CreatePurchaseOrderEntries < ActiveRecord::Migration
  def change
    create_table :purchase_order_entries do |t|
      t.integer :purchase_order_id  

      t.string  :code
      t.integer :item_id 

      t.integer :quantity 
      t.decimal :unit_price , :precision => 11, :scale => 2 , :default => 0
      t.decimal :total_price , :precision  => 11, :scale => 2 , :default => 0  # 10^9 << max value
      
      t.boolean :is_fulfilled, :default => false 

      t.boolean :is_confirmed, :default => false  

      t.boolean :is_deleted, :default => false

      t.timestamps
    end
  end
end
