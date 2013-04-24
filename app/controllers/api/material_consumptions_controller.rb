class Api::MaterialConsumptionsController < Api::BaseApiController
  
  def index
    @parent = ServiceExecution.find_by_id params[:service_execution_id]
    
    @objects = @parent.active_material_consumptions.
                joins(:service_execution, :usage_option=> [:item, :service_component ]).
                page(params[:page]).per(params[:limit]).order("id DESC")
                
    @total = @parent.active_material_consumptions.count    
  end

  def create
    @parent = ServiceExecution.find_by_id params[:service_execution_id]
    
    params[:material_consumption][:service_execution_id] = params[:service_execution_id]
    params[:material_consumption][:sales_order_entry_id] = @parent.sales_order_entry_id 
    @object = MaterialConsumption.create_object( params[:material_consumption] )  
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :material_consumptions => [@object] , 
                        :total => @parent.active_material_consumptions.count }  
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
    @object = MaterialConsumption.find_by_id params[:id] 
    @parent = @object.service_execution 
    
    @object.update_object(params[:material_consumption])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :material_consumptions => [@object],
                        :total => @parent.active_material_consumptions.count  } 
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
    @object = MaterialConsumption.find(params[:id])
    @parent = @object.service_execution 
    @object.delete_object

    if  ( not @object.persisted? )
      render :json => { :success => true, :total => @parent.active_material_consumptions.count }  
    else
      render :json => { :success => false, :total =>@parent.active_material_consumptions.count }  
    end
  end
  
end
