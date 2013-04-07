class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      
      t.string :name  
      
      # it is updated whenever there is stock mutation takes place  
      t.decimal :average_cost , :precision => 11, :scale => 2 , :default => 0  # 10^9 << max value 
      # kinda caching it for future use 
      
      t.decimal :selling_price , :precision => 11, :scale => 2 , :default => 0  # 10^9 << max value
      
      
      # Stock Mutation.
      t.integer :ready , :default           => 0 
      t.integer :pending_receival , :default => 0 
      t.integer :pending_delivery , :default => 0  
      
      
      t.boolean :is_deleted , :default => false

      t.timestamps
    end
  end
end
