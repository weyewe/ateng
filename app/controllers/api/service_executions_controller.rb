class Api::ServiceExecutionsController < Api::BaseApiController
  
  def index
    @parent = SalesOrderEntry.find_by_id params[:sales_order_entry_id]
    @objects = @parent.active_service_executions.
                joins(:sales_order_entry, :service_component ).
                page(params[:page]).per(params[:limit]).order("id DESC")
    @total = @parent.active_service_executions.count
    
    # render :json => { :service_executions => @objects , :total => @total , :success => true }
  end

  def create
   
    @parent = SalesOrderEntry.find_by_id params[:sales_order_entry_id]
    
    params[:service_execution][:sales_order_entry_id] = params[:sales_order_entry_id]
    @object = ServiceExecution.create_object( params[:service_execution] )  
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :service_executions => [@object] , 
                        :total => @parent.active_service_executions.count }  
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
    @object = ServiceExecution.find_by_id params[:id] 
    @parent = @object.sales_order_entry 
    
    params[:service_execution][:sales_order_entry_id] = params[:sales_order_entry_id]
    @object.update_object(params[:service_execution])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :service_executions => [@object],
                        :total => @parent.active_service_executions.count  } 
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
    @object = ServiceExecution.find(params[:id])
    @parent = @object.sales_order_entry 
    @object.delete_object

    if  ( not @object.persisted? )
      render :json => { :success => true, :total => @parent.active_service_executions.count }  
    else
      render :json => { :success => false, :total =>@parent.active_service_executions.count }  
    end
  end
  
end
