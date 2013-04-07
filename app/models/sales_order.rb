class SalesOrder < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :customer  
  has_many :sales_order_entries 
  
  
  def self.create( params  )  
    new_object  = self.new
    new_object.customer_id = params[:customer_id]
    
    if new_object.save
      new_object.generate_code
    end 
    
    return new_object 
  end
  
  def update( params ) 
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
    

    ActiveRecord::Base.transaction do
      
      self.is_confirmed = true 
      self.confirmer_id = employee.id
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
