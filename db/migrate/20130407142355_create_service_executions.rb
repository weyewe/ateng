class CreateServiceExecutions < ActiveRecord::Migration
  def change
    create_table :service_executions do |t|

      t.integer :service_id 
      t.integer :service_component_id 
      t.integer :employee_id 
      
      t.decimal :commission_amount  , :precision => 11, :scale => 2 , :default => 0
      
      t.boolean :is_confirmed , :default => false  # confirmed means payment of the fee 
      
      t.boolean :is_commission_approved, :default => false # if commission cycle is closed
      
      t.boolean :is_deleted , :default => false 
      t.timestamps
    end
  end
end
