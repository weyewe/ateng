class CreateServiceComponents < ActiveRecord::Migration
  def change
    create_table :service_components do |t|
      
      t.string :name 
      
      # what if they update the commission_amount? We must keep track of the history
      # instead of the amount, go for another object => Commission 
      # so, we will know at what service level 
      # when the commission is changed => find those unpaid service, update the commission
      t.decimal :commission_amount , :precision => 11, :scale => 2 , :default => 0
      t.integer :service_id 
      
      t.boolean :is_deleted , :default => false 

      t.timestamps
    end
  end
end
