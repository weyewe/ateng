class CreateStockEntryMutations < ActiveRecord::Migration
  def change
    create_table :stock_entry_mutations do |t|
      t.integer :stock_entry_id 
      t.integer :stock_mutation_id 
      
      t.integer :quantity 
      t.integer :mutation_case 
      
      t.integer :mutation_status, :default => MUTATION_STATUS[:addition]
      
      # t.boolean :is_stock_entry_creation , :default => false  # on stock_entry creation, it will
      # auto create stock_entry_mutation and stock_mutation

      t.timestamps
    end
  end
end
