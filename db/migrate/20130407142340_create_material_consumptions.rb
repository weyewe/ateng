class CreateMaterialConsumptions < ActiveRecord::Migration
  def change
    create_table :material_consumptions do |t|
      
    
      t.integer :sales_order_entry_id 
      t.integer :material_usage_id 
      t.integer :usage_option_id 
      
      
      t.boolean :is_confirmed, :default => false 

      t.timestamps
    end
  end
end
