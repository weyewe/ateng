class CreateMaterialUsages < ActiveRecord::Migration
  def change
    create_table :material_usages do |t|
      t.string :name 
      t.integer :service_component_id 

      t.timestamps
    end
  end
end
