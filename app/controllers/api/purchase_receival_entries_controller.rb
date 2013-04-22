class Api::PurchaseReceivalEntriesController < Api::BaseApiController
  
  def index
    @parent = PurchaseReceival.find_by_id params[:purchase_receival_id]
    @objects = @parent.active_purchase_receival_entries.joins(:item, :purchase_receival).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = @parent.active_purchase_receival_entries.count
  end

  def create
    @parent = PurchaseReceival.find_by_id params[:purchase_receival_id]
    @object = PurchaseReceivalEntry.create_object( @parent,  params[:purchase_receival_entry] )  
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :purchase_receival_entries => [@object] , 
                        :total => @parent.active_purchase_receival_entries.count }  
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
      
      render :json => msg                         
    end
  end

  def update
    
    @object = PurchaseReceivalEntry.find_by_id params[:id] 
    @parent = @object.purchase_receival 
    @object.update_object(   params[:purchase_receival_entry])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :purchase_receival_entries => [@object],
                        :total => @parent.active_purchase_receival_entries.count  } 
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
      
      render :json => msg 
    end
  end

  def destroy
    @object = PurchaseReceivalEntry.find(params[:id])
    @parent = @object.purchase_receival 
    @object.delete_object 

    if ( @object.persisted? and @object.is_deleted ) or ( not @object.persisted? )
      render :json => { :success => true, :total => @parent.active_purchase_receival_entries.count }  
    else
      render :json => { :success => false, :total =>@parent.active_purchase_receival_entries.count }  
    end
  end
end
