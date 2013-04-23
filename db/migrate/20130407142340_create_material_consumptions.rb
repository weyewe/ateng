class CreateMaterialConsumptions < ActiveRecord::Migration
  def change
    create_table :material_consumptions do |t|
      
    
      t.integer :sales_order_entry_id 
      t.integer :service_component_id 
      t.integer :usage_option_id 
      
      
      t.integer :service_execution_id 
      
      t.boolean :is_confirmed, :default => false 
      t.boolean :is_deleted, :default => false 
      t.timestamps
    end
  end
end
