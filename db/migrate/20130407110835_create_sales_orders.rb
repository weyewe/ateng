class CreateSalesOrders < ActiveRecord::Migration
  def change
    create_table :sales_orders do |t|
      t.integer :customer_id 
      
      t.string  :code 
      
      # not sure about order_date 
      t.date    :order_date 
      # t.integer :payment_term , :default => PAYMENT_TERM[:credit]
      
      # maybe we are not even using this downpayment. must be paid in cash. 
      # we are in the retail business 
      # t.decimal :downpayment_amount , :precision => 11, :scale => 2 , :default => 0
      
      
      t.boolean :is_confirmed , :default => false  
      t.integer :confirmer_id 
      t.datetime :confirmed_at 
      
      t.boolean :is_deleted , :default => false

      t.timestamps
    end
  end
end
