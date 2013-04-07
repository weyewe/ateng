class CreateMaterialUsages < ActiveRecord::Migration
  def change
    create_table :material_usages do |t|

      t.timestamps
    end
  end
end
