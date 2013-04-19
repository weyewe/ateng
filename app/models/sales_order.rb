class SalesOrder < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :customer  
  has_many :sales_order_entries 
  
  def validate_enough_item_quantity_for_confirmation
    item_quantity_hash = {}
    # key is the item_id 
    # value is the quantity required 
    self.active_sales_order_entries.each do |soe|
      if soe.is_product?
        if item_quantity_hash[soe.entry_id].nil?
          item_quantity_hash[soe.entry_id] = soe.quantity 
        else
          item_quantity_hash[soe.entry_id] = soe.quantity  + item_quantity_hash[soe.entry_id]
        end
      else
        soe.material_consumptions.joins(:usage_option).each do |material_consumption|
          usage_option = material_consumption.usage_option
          if item_quantity_hash[usage_option.item_id].nil?
            item_quantity_hash[usage_option.item_id] =  usage_option.quantity 
          else
            item_quantity_hash[usage_option.item_id] += usage_option.quantity  + item_quantity_hash[usage_option.item_id] 
          end
        end
      end
    end
    
    item_quantity_hash.each do |key, value |
      item = Item.find_by_id(key) 
      if item.ready <  value 
        errors.add(:generic_error, "Kuantitas item #{item.name} tidak cukup (ready = #{item.ready})")
        return 
      end
    end
  end
  
  def self.create_object( params  )  
    new_object  = self.new
    new_object.customer_id = params[:customer_id]
    
    if new_object.save
      new_object.generate_code
    end 
    
    return new_object 
  end
  
  def update_object( params ) 
    self.customer_id = params[:customer_id]
    self.save
  end
  

  def active_sales_order_entries
    self.sales_order_entries.where(:is_deleted => false ).order("id ASC")
  end
   

  def generate_code
  
    start_datetime = Date.today.at_beginning_of_month.to_datetime
    end_datetime = Date.today.next_month.at_beginning_of_month.to_datetime

    counter = self.class.where{
      (self.created_at >= start_datetime)  & 
      (self.created_at < end_datetime )
      }.count

    if self.is_confirmed?
      counter = self.class.where{
        (self.created_at >= start_datetime)  & 
        (self.created_at < end_datetime ) & 
        (self.is_confirmed.eq true )
        }.count
    end


    header = ""
    if not self.is_confirmed?  
      header = "[pending]"
    end


    string = "#{header}SO" + "/" + 
    self.created_at.year.to_s + '/' + 
    self.created_at.month.to_s + '/' + 
    counter.to_s

    self.code =  string 
    self.save 
  end
  
  def confirm  
    return nil if self.is_confirmed? 
    return nil if self.active_sales_order_entries.count ==0 
    
    self.validate_enough_item_quantity_for_confirmation
    return self if self.errors.size != 0 
    
    ActiveRecord::Base.transaction do
      
      self.is_confirmed = true 
      self.confirmed_at = DateTime.now  
      self.save
      self.generate_code
      
      self.active_sales_order_entries.each do |sales_order_entry|
        sales_order_entry.confirm 
      end
    end 
  end
  
  def delete 
    return nil if self.is_confirmed? 
    self.is_deleted = true 
    self.save 
  end
   
end
