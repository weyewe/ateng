class CreatePriceHistories < ActiveRecord::Migration
  def change
    create_table :price_histories do |t|

      t.timestamps
    end
  end
end
