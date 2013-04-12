class CreateStockEntries < ActiveRecord::Migration
  def change
    
    create_table :stock_entries do |t|
      t.integer :creator_id 
      
      t.integer :source_document_id  
      t.string :source_document   
      
      t.integer :source_document_entry_id
      t.string :source_document_entry 
       
      t.integer :quantity  
      t.integer :item_id
      
      t.integer :remaining_quantity # if it is zero, then this stock entry is finished 
      # item.ready = StockEntry.where(:item_id => item.id, :is_finished => true ).sum("remaining_quantity")  
      
      
      # how can we enforce FIFO?
      # one way: to perform shifting on stock_entry contraction/expansion 
      t.boolean :is_prime , :default => true 
      t.integer :parent_stock_entry_id  
      
      t.boolean :is_finished, :default => false 
      t.decimal :base_price_per_piece, :precision => 12, :scale => 2 , :default => 0 # 10^9 << max value
       
      t.timestamps
    end
  end
end
