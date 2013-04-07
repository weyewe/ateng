class Item < ActiveRecord::Base
  include UniqueNonDeleted
  validate :unique_non_deleted_name 
  validates_presence_of :name
   
  has_many :material_usages, :through => :usage_options
  has_many :usage_options 
   
  def self.active_objects
    Item.where(:is_deleted => false).order("id DESC")
  end
   
  
  def self.create( params) 
    new_object = Item.new  
    
    new_object.name                      = params[:name] 
    new_object.selling_price = params[:selling_price]

    new_object.save 
    return new_object 
  end
  
  def  update( params)  
    self.name                      = params[:name] 
    self.selling_price = params[:selling_price] 
    
    self.save 
    return self 
  end
  
  
 
  
  def delete 
    self.is_deleted = true
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
  BECAUSE OF SALES
=end
  def deduct_ready_quantity( quantity)
    self.ready -= quantity 
    self.save
  end
  
  def add_ready_quantity( quantity ) 
    self.ready += quantity 
    self.save
  end
  
=begin
  BECAUSE OF SCRAP -> SCRAP EXCHANGE
=end
  
  def deduct_scrap_quantity( quantity )
    self.scrap -= quantity 
    self.ready += quantity 
    self.save
  end
  
  def add_scrap_quantity( quantity ) 
    self.scrap += quantity 
    self.ready -= quantity 
    self.save 
  end
  
end
