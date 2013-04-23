class Api::MaterialConsumptionsController < Api::BaseApiController
  
  def index
    @parent = SalesOrderEntry.find_by_id params[:sales_order_entry_id]
    @objects = @parent.active_material_consumptions.
                joins(:sales_order_entry, :usage_option=> [:item, :service_component ]).
                page(params[:page]).per(params[:limit]).order("id DESC")
    @total = @parent.active_material_consumptions.count
    
    # render :json => { :material_consumptions => @objects , :total => @total , :success => true }
  end

  def create
   
    @parent = SalesOrderEntry.find_by_id params[:sales_order_entry_id]
    
    params[:material_consumption][:sales_order_entry_id] = params[:sales_order_entry_id]
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
    @parent = @object.sales_order_entry 
    
    params[:material_consumption][:sales_order_entry_id] = params[:sales_order_entry_id]
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
    @parent = @object.sales_order_entry 
    @object.delete_object

    if  ( not @object.persisted? )
      render :json => { :success => true, :total => @parent.active_material_consumptions.count }  
    else
      render :json => { :success => false, :total =>@parent.active_material_consumptions.count }  
    end
  end
  
end
