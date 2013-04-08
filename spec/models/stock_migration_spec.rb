require 'spec_helper'

describe StockMigration do


  # PRECONDITION 
  it 'should not allow quantity to be less than zero'
  it 'should not allow price to be less than zero'
  it 'should not allow duplicate migration for a given item'
  it 'should auto confirm'
  
  context "post confirm" do
    it 'should create stock_entry, stock_entry_mutation, and stock_mutation'
    it 'should increate the item_ready quantity and inventory value of the item'
    it 'should set the stock_entry remaining quantity to be equal with stock_migration quantity'
    
    context "update post confirm" do
      it 'should change the quantity in stock_entry, stock_mutation, stock_entry_mutation'
      it 'should change the item_ready quantity'
      it 'should change the inventory_value  '
    end
    
    context "stock_entry consumption (through sales?)" do
      it 'should reduce remaining quantity'
      
      context "stock_migration quantity update [contraction]" do
      end
      
      context 'stock_migration quantity update [expansion]' do
      end
    end
  end
end
