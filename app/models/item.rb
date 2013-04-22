class Item < ActiveRecord::Base
  include UniqueNonDeleted
  validate :unique_non_deleted_name 
  validates_presence_of :name
  
  has_many :stock_entries 
  has_many :purchase_order_entries
  has_many :purchase_receival_entries 
  has_many :sales_order_entries , :as => :sellable 
  
  def self.active_objects
    Item.where(:is_deleted => false).order("id DESC")
  end
   
  
  def self.create_object( params) 
    new_object = Item.new  
    
    new_object.name              = params[:name] 
    new_object.selling_price     = BigDecimal( params[:selling_price] ) 
    new_object.commission_amount = BigDecimal( params[:commission_amount]  ) 


    new_object.save 
    return new_object 
  end
  
  def  update_object( params)  
    self.name              = params[:name] 
    self.selling_price     = BigDecimal( params[:selling_price] )
    self.commission_amount = BigDecimal( params[:commission_amount])

    if self.save 
      
    end
    return self 
  end
  
  
 
  
  def delete_object
    self.is_deleted = true
    self.save 
  end
  
  def update_inventory_value
  end
  
  def update_ready_quantity
    # puts "Inside update_ready_quantity\n"*3
    self.ready = self.stock_entries.where{
      (remaining_quantity.not_eq 0 )
    }.sum("remaining_quantity")
    
    self.save 
  end
  
  def add_stock_and_recalculate_average_cost_post_stock_entry_addition( new_stock_entry )  
     total_amount = ( self.average_cost * self.ready)   + 
                    ( new_stock_entry.base_price_per_piece * new_stock_entry.quantity ) 

     total_quantity = self.ready + new_stock_entry.quantity 

     if total_quantity == 0 
       self.average_cost = BigDecimal('0')
     else
       self.average_cost = total_amount / total_quantity .to_f
     end
     self.ready = total_quantity 
     self.save 

   end

=begin
UPDATE ITEM STATISTIC
=end

  def update_pending_receival
    self.pending_receival = self.purchase_order_entries.where(:is_confirmed => true, :is_deleted => false  ).sum("quantity") - 
                            self.purchase_receival_entries.where(:is_confirmed => true, :is_deleted => false  ).sum("quantity")
    self.save 
  end
end
