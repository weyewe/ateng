class Api::SalesOrdersController < Api::BaseApiController
  
  def index
    @objects = SalesOrder.joins(:customer).active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
    @total = SalesOrder.active_objects.count
    # render :json => { :sales_orders => @objects , :total => SalesOrder.active_objects.count, :success => true }
  end

  def create
    @object = SalesOrder.create_object(  params[:sales_order] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :sales_orders => [@object] , 
                        :total => SalesOrder.active_objects.count }  
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
    
    @object = SalesOrder.find_by_id params[:id] 
    @object.update_object( params[:sales_order])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :sales_orders => [@object],
                        :total => SalesOrder.active_objects.count  } 
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
    @object = SalesOrder.find(params[:id])
    @object.delete 

    if  ( @object.is_confirmed? and @object.is_deleted)  or  (   not @object.persisted?)
      render :json => { :success => true, :total => SalesOrder.active_objects.count }  
    else
      render :json => { 
                  :success => false, 
                  :total => SalesOrder.active_objects.count,
                  :message => {
                    :errors => extjs_error_format( @object.errors )  
                  }
               }  
    end
  end
  
  def confirm
    @object = SalesOrder.find_by_id params[:id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @object.confirm   
    
    if @object.errors.size == 0 and @object.is_confirmed? 
      render :json => { :success => true, :total => SalesOrder.active_objects.count }  
    else
      render :json => { :success => false, :total => SalesOrder.active_objects.count, 
                        :message => {
                          :errors => extjs_error_format( @object.errors )  
                        }
                      }  
    end
  end
end
