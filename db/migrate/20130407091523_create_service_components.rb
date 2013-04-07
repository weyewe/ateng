class CreateServiceComponents < ActiveRecord::Migration
  def change
    create_table :service_components do |t|
      
      t.decimal :commission_amount , :precision => 11, :scale => 2 , :default => 0
      t.integer :service 

      t.timestamps
    end
  end
end
