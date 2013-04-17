class CreateMaterialUsages < ActiveRecord::Migration
  def change
    create_table :material_usages do |t|
      t.string :name 
      t.integer :service_component_id 
      
      
      t.boolean :is_deleted , :default => false 

      t.timestamps
    end
  end
end
