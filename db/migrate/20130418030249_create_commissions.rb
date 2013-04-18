class CreateCommissions < ActiveRecord::Migration
  def change
    create_table :commissions do |t|
      t.decimal :commission_amount  , :precision => 11, :scale => 2 , :default => 0
      
      t.references :commissionable , :polymorphic => true
      
      t.integer :employee_id 
      t.boolean :is_commission_approved, :default => false # if commission cycle is closed

      t.timestamps
    end
  end
end
