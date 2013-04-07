class CreateUsageOptions < ActiveRecord::Migration
  def change
    create_table :usage_options do |t|
      t.integer :material_usage_id 
      t.integer :item_id 
      t.integer :quantity 

      t.timestamps
    end
  end
end
