class StockMutation < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :quantity, :stock_entry_id, :source_document_entry_id, 
                  :creator_id, :source_document_id, :source_document_entry,
                  :source_document, :deduction_case,
                  :mutation_case, :mutation_status,
                  :item_id, :item_status,
                  :scrap_item_id
                  
  belongs_to :item
  
  
  has_many :stock_entry_mutations
  has_many :stock_entries, :through => :stock_entry_mutations
   
   
  after_save :update_item_statistics
  after_create :update_item_statistics

  def update_item_statistics
    # self.reload 
    #  item.update_ready_quantity
  end
  
  def update_quantity(quantity )
    self.quantity = quantity
    self.save 
  end
  
  def self.generate_from_document_entry( stock_entry, document_entry )
    new_object = StockMutation.new 
    
    new_object.quantity                 = document_entry.quantity
    new_object.item_id                  = document_entry.item_id
    
    new_object.source_document_entry_id = document_entry.id    
    new_object.source_document_id       = document_entry.id 
    new_object.source_document_entry    = document_entry.class.to_s
    new_object.source_document          = document_entry.class.to_s
    
    if document_entry.class.to_s == "StockMigration"
      mutation_case = MUTATION_CASE[:stock_migration] 
      mutation_status = MUTATION_STATUS[:addition] 
    elsif   document_entry.class.to_s == "PurchaseReceivalEntry"
      mutation_case = MUTATION_CASE[:purchase_receival] 
      mutation_status = MUTATION_STATUS[:addition]
    end
    
    
    new_object.mutation_case = mutation_case
    new_object.mutation_status = mutation_status
    
    if new_object.save
      StockEntryMutation.create(
        :stock_entry_id    => stock_entry.id , 
        :stock_mutation_id => new_object.id ,
        :quantity          =>  new_object.quantity ,
        :case              => mutation_case,  
        :mutation_status   =>  mutation_status 
      ) 
    end
  end
   
########################################################
########################################################
##############      The rest is for latter 
########################################################
########################################################
  
  
  # Try it with stock_migration (the FIFO for stock_entry ) 
  
  
  
  
  
  
  
  def StockMutation.create_stock_adjustment( employee, stock_adjustment)
    item = stock_adjustment.item 
    
    new_object = StockMutation.new 
    
    new_object.quantity                     = stock_adjustment.adjustment_quantity 
    new_object.creator_id                   = employee.id
    new_object.source_document_entry_id     = stock_adjustment.id
    new_object.source_document_id           = stock_adjustment.id
    new_object.source_document_entry        = stock_adjustment.class.to_s
    new_object.source_document              = stock_adjustment.class.to_s
    new_object.mutation_case                =  MUTATION_CASE[:stock_adjustment]
    new_object.item_id                      = item.id 
    
    
    
    
    if stock_adjustment.adjustment_case == STOCK_ADJUSTMENT_CASE[:addition]
      new_object.mutation_status = MUTATION_STATUS[:addition]
    elsif stock_adjustment.adjustment_case == STOCK_ADJUSTMENT_CASE[:deduction]
      new_object.mutation_status = MUTATION_STATUS[:deduction]
    end
    new_object.save 
  end
  
  
  def StockMutation.generate_purchase_receival_stock_mutation( purchase_receival_entry  ) 
    new_object = StockMutation.new 
    
    new_object.creator_id               = purchase_receival_entry.purchase_receival.creator_id
    new_object.quantity                 = purchase_receival_entry.quantity
    new_object.source_document_entry_id = purchase_receival_entry.id 
    new_object.source_document_id       = purchase_receival_entry.purchase_receival_id
    new_object.source_document_entry    = purchase_receival_entry.class.to_s
    new_object.source_document          = purchase_receival_entry.purchase_receival.class.to_s
    new_object.item_id                  = purchase_receival_entry.purchase_order_entry.item_id 
    new_object.mutation_case            = MUTATION_CASE[:purchase_receival] 
    new_object.mutation_status          = MUTATION_STATUS[:addition]  
    
    new_object.save
  end
  
  def purchase_receival_change_item( purchase_receival_entry ) 
    self.quantity = purchase_receival_entry.quantity
    self.item_id = purchase_receival_entry.purchase_order_entry.item_id 
    self.save 
  end
  
=begin
  SPECIFIC FOR DELIVERY 
=end
  
  def self.create_or_update_delivery_stock_mutation( delivery_entry ) 
    past_object = self.where(
      :source_document_entry => delivery_entry.class.to_s,
      :source_document_entry_id => delivery_entry.id,
      :mutation_case => MUTATION_CASE[:delivery],
      :mutation_status => MUTATION_STATUS[:deduction]
    ).first 
    
    if past_object.nil? 
      new_object = self.new
      new_object.creator_id               = delivery_entry.delivery.creator_id
      new_object.quantity                 = delivery_entry.quantity_sent
      new_object.source_document_entry_id = delivery_entry.id 
      new_object.source_document_id       = delivery_entry.delivery.id 
      new_object.source_document_entry    = delivery_entry.class.to_s
      new_object.source_document          = delivery_entry.delivery.class.to_s
      new_object.item_id                  = delivery_entry.sales_order_entry.item_id 
      new_object.mutation_case            = MUTATION_CASE[:delivery] 
      new_object.mutation_status          = MUTATION_STATUS[:deduction]
      new_object.save 
    else
      past_object.quantity = delivery_entry.quantity_sent
      past_object.item_id = delivery_entry.sales_order_entry.item_id 
     
      past_object.save 
    end
  end
  
  def self.create_or_update_delivery_return_stock_mutation( sales_return_entry ) 
    return nil if not  sales_return_entry.is_confirmed? 
    
    
    past_object = self.where(
      :source_document_entry => sales_return_entry.class.to_s,
      :source_document_entry_id => sales_return_entry.id,
      :mutation_case => MUTATION_CASE[:delivery_returned],
      :mutation_status => MUTATION_STATUS[:addition]
    ).first 
    item = sales_return_entry.delivery_entry.sales_order_entry.item 
    
    if past_object.nil? and sales_return_entry.quantity  != 0 
      new_object = self.new
      new_object.creator_id               = sales_return_entry.sales_return.creator_id
      new_object.quantity                 = sales_return_entry.quantity 
      new_object.source_document_entry_id = sales_return_entry.id 
      new_object.source_document_id       = sales_return_entry.sales_return.id 
      new_object.source_document_entry    = sales_return_entry.class.to_s
      new_object.source_document          = sales_return_entry.sales_return.class.to_s
      new_object.item_id                  = item.id 
      new_object.mutation_case            = MUTATION_CASE[:delivery_returned] 
      new_object.mutation_status          = MUTATION_STATUS[:addition]
      new_object.save 
    elsif not past_object.nil? and sales_return_entry.quantity  !=  0
     
      past_object.quantity  = sales_return_entry.quantity 
      past_object.item_id = item.id  
      past_object.save 
    elsif not past_object.nil? and sales_return_entry.quantity  ==  0
      past_object.destroy 
    end
  end
   
 
  def self.create_or_update_delivery_lost_stock_mutation( delivery_lost_entry ) 
    return nil if not delivery_lost_entry.is_confirmed? 
    past_object = self.where(
     :source_document_entry => delivery_lost_entry.class.to_s,
     :source_document_entry_id => delivery_lost_entry.id,
     :mutation_case => MUTATION_CASE[:delivery_lost],
     :mutation_status => MUTATION_STATUS[:deduction]
    ).first 

    item = delivery_lost_entry.delivery_entry.sales_order_entry.item 
    if past_object.nil? and delivery_lost_entry.quantity != 0 
     new_object = self.new
     new_object.creator_id               = delivery_lost_entry.delivery_lost.creator_id
     new_object.quantity                 = delivery_lost_entry.quantity
     new_object.source_document_entry_id = delivery_lost_entry.id 
     new_object.source_document_id       = delivery_lost_entry.delivery_lost.id 
     new_object.source_document_entry    = delivery_lost_entry.class.to_s
     new_object.source_document          = delivery_lost_entry.delivery_lost.class.to_s
     new_object.item_id                  = item.id  
     new_object.mutation_case            = MUTATION_CASE[:delivery_lost] 
     new_object.mutation_status          = MUTATION_STATUS[:deduction]
     new_object.save 
    elsif not past_object.nil? and delivery_lost_entry.quantity !=  0

     past_object.quantity = delivery_lost_entry.quantity
     past_object.item_id = item.id 
     past_object.save 
    elsif not past_object.nil? and delivery_lost_entry.quantity ==  0
     past_object.destroy 
    end
  end
  
  # def StockMutation.create_delivery_return_stock_mutation( delivery_entry  ) 
  #   return nil if delivery_entry.quantity_returned == 0 
  #   new_object = StockMutation.new 
  #   
  #   new_object.creator_id               = delivery_entry.delivery.creator_id
  #   new_object.quantity                 = delivery_entry.quantity_returned 
  #   new_object.source_document_entry_id = delivery_entry.id 
  #   new_object.source_document_id       = delivery_entry.delivery.id 
  #   new_object.source_document_entry    = delivery_entry.class.to_s
  #   new_object.source_document          = delivery_entry.delivery.class.to_s
  #   new_object.item_id                  = delivery_entry.item_id 
  #   new_object.mutation_case            = MUTATION_CASE[:delivery_returned] 
  #   new_object.mutation_status          = MUTATION_STATUS[:addition]  
  #   
  #   new_object.save
  # end
  # 
  # def StockMutation.create_delivery_lost_stock_mutation( delivery_entry  ) 
  #   return nil if delivery_entry.quantity_lost == 0 
  #   new_object = StockMutation.new 
  #   
  #   new_object.creator_id               = delivery_entry.delivery.creator_id
  #   new_object.quantity                 = delivery_entry.quantity_lost 
  #   new_object.source_document_entry_id = delivery_entry.id 
  #   new_object.source_document_id       = delivery_entry.delivery.id 
  #   new_object.source_document_entry    = delivery_entry.class.to_s
  #   new_object.source_document          = delivery_entry.delivery.class.to_s
  #   new_object.item_id                  = delivery_entry.item_id 
  #   new_object.mutation_case            = MUTATION_CASE[:delivery_lost] 
  #   new_object.mutation_status          = MUTATION_STATUS[:deduction]  
  #   
  #   new_object.save
  # end
  # 
  
  
  
  
  
  
  
  
#########################################
#########################################
#########################################
#########################################
####################### UNUSED
#########################################
#########################################
#########################################
  
  # (gonna be deprecated soon)
  def StockMutation.deduct_ready_stock(
            employee, 
            quantity, 
            item, 
            source_document, 
            source_document_entry,
            mutation_case, 
            mutation_status  
          )

        requested_quantity =  quantity
        supplied_quantity = 0 

        while supplied_quantity != requested_quantity
          unfulfilled_quantity = requested_quantity - supplied_quantity 
          stock_entry =  StockEntry.first_available_stock(  item )

          #  stock_entry.nil? raise error  # later.. 
          if stock_entry.nil?
            raise ActiveRecord::Rollback, "Can't be executed. No Item in the stock" 
          end

          available_quantity = stock_entry.available_quantity 

          served_quantity = 0 
          if unfulfilled_quantity <= available_quantity 
            served_quantity = unfulfilled_quantity 
          else
            served_quantity = available_quantity 
          end

          stock_entry.update_usage(served_quantity) 
          supplied_quantity += served_quantity 

          StockMutation.create(
            :quantity            => served_quantity  ,
            :stock_entry_id      =>  stock_entry.id ,
            :creator_id          =>  employee.id ,
            :source_document_entry_id  =>  source_document_entry.id  ,
            :source_document_id  =>  source_document.id  ,
            :source_document_entry     =>  source_document_entry.class.to_s,
            :source_document    =>  source_document.class.to_s,
            :mutation_case      => mutation_case,
            :mutation_status => mutation_status,
            :item_id => stock_entry.item_id ,
            :item_status => ITEM_STATUS[:ready]
          )

        end
    end
    
   
   
  def StockMutation.create_mutation_by_stock_conversion( object_params)
    new_object = StockMutation.new 
    
    new_object.creator_id               = object_params[:creator_id]
    
    new_object.quantity                 = object_params[:quantity]
    new_object.stock_entry_id           = object_params[:stock_entry_id] 
    
    new_object.source_document_entry_id = object_params[:source_document_entry_id]     
    new_object.source_document_id       = object_params[:source_document_id]     
    new_object.source_document_entry    = object_params[:source_document_entry]  
    new_object.source_document          = object_params[:source_document]   
    new_object.item_id                  = object_params[:item_id]   
    new_object.mutation_case            = MUTATION_CASE[:stock_conversion_target] 
    new_object.mutation_status          = MUTATION_STATUS[:addition]  
    
    new_object.save 
  end
  
  
  def render_mutation_case
    if self.mutation_case == MUTATION_CASE[:stock_migration] 
      return "Migrasi"
    elsif self.mutation_case == MUTATION_CASE[:purchase_receival] 
      return "Penerimaan"
    elsif self.mutation_case == MUTATION_CASE[:stock_adjustment]
      return "Penyesuaian"
    elsif self.mutation_case == MUTATION_CASE[:delivery] 
      return "Pengiriman"
    elsif self.mutation_case == MUTATION_CASE[:delivery_lost] 
      return "Hilang Pengiriman" 
    elsif self.mutation_case == MUTATION_CASE[:delivery_returned]   
      return "Retur Pengiriman"
    else 
      return ""
    end
  end
  
  def render_mutation_status
    if self.mutation_status == MUTATION_STATUS[:deduction] 
       "-"
    elsif self.mutation_status == MUTATION_STATUS[:addition] 
       "+"
    end
  end
  
  def document_code
    class_name  = self.source_document 
    document_id = self.source_document_id
    document = eval("#{class_name}.find_by_id(#{document_id})")
    if not document.code.nil?
      return document.code 
    else
      return class_name 
    end
  end
   
  
end



