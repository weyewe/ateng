class Api::SalesOrderEntriesController < Api::BaseApiController
  
  def index
    @parent = SalesOrder.find_by_id params[:sales_order_id]
    @objects = @parent.active_sales_order_entries.joins(:item, :sales_order).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = @parent.active_sales_order_entries.count
  end

  def create
    @parent = SalesOrder.find_by_id params[:sales_order_id]
    @object = SalesOrderEntry.create_by_employee(current_user, @parent,  params[:sales_order_entry] )  
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :sales_order_entries => [@object] , 
                        :total => @parent.active_sales_order_entries.count }  
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
    
    @object = SalesOrderEntry.find_by_id params[:id] 
    @parent = @object.sales_order 
    @object.update_by_employee(current_user,  params[:sales_order_entry])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :sales_order_entries => [@object],
                        :total => @parent.active_sales_order_entries.count  } 
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
    @object = SalesOrderEntry.find(params[:id])
    @parent = @object.sales_order 
    @object.delete(current_user)

    if ( @object.persisted? and @object.is_deleted ) or ( not @object.persisted? )
      render :json => { :success => true, :total => @parent.active_sales_order_entries.count }  
    else
      render :json => { :success => false, :total =>@parent.active_sales_order_entries.count }  
    end
  end
  
  def search
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    
    customer_id = params[:customer_id]
    
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    if  selected_id.nil?
      @objects = SalesOrderEntry.joins(:item, :sales_order ).where{ (item.name =~ query )   & 
                                (is_deleted.eq false )  & 
                                (sales_order.customer_id.eq customer_id)
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = SalesOrderEntry.joins(:item, :sales_order).where{ (id.eq selected_id)  & 
                                (is_deleted.eq false ) & 
                                (sales_order.customer_id.eq customer_id)
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    end
    
    @total = @objects.count
    @success = true 
    # render :json => { :records => @objects , :total => @objects.count, :success => true }
  end
end
