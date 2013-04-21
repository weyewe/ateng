class Api::MaterialUsagesController < Api::BaseApiController
  
  def index
    @parent = ServiceComponent.find_by_id params[:service_component_id]
    @objects = @parent.active_material_usages.joins(:service_component).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = @parent.active_material_usages.count
    
    render :json => { :material_usages => @objects , :total => @total , :success => true }
  end

  def create
   
    @parent = ServiceComponent.find_by_id params[:service_component_id]
    
    params[:material_usage][:service_component_id] = params[:service_component_id]
    @object = MaterialUsage.create_object( params[:material_usage] )  
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :material_usages => [@object] , 
                        :total => @parent.active_material_usages.count }  
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
    @object = MaterialUsage.find_by_id params[:id] 
    @parent = @object.service_component 
    
    params[:material_usage][:service_component_id] = params[:service_component_id]
    @object.update_object(params[:material_usage])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :material_usages => [@object],
                        :total => @parent.active_material_usages.count  } 
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
    @object = MaterialUsage.find(params[:id])
    @parent = @object.service_component 
    @object.delete_object

    if  ( not @object.persisted? )
      render :json => { :success => true, :total => @parent.active_material_usages.count }  
    else
      render :json => { :success => false, :total =>@parent.active_material_usages.count }  
    end
  end
  
  # def search
  #   search_params = params[:query]
  #   selected_id = params[:selected_id]
  #   if params[:selected_id].nil?  or params[:selected_id].length == 0 
  #     selected_id = nil
  #   end
  #   
  #   customer_id = params[:customer_id]
  #   
  #   query = "%#{search_params}%"
  #   # on PostGre SQL, it is ignoring lower case or upper case 
  #   
  #   if  selected_id.nil?
  #     @objects = MaterialUsage.joins(  :service_component ).where{ (template_material_usage.name =~ query )   & 
  #                               (is_deleted.eq false )  & 
  #                               (service_component.customer_id.eq customer_id)
  #                             }.
  #                       page(params[:page]).
  #                       per(params[:limit]).
  #                       order("id DESC")
  #   else
  #     @objects = MaterialUsage.joins( :service_component).where{ (id.eq selected_id)  & 
  #                               (is_deleted.eq false ) & 
  #                               (service_component.customer_id.eq customer_id)
  #                             }.
  #                       page(params[:page]).
  #                       per(params[:limit]).
  #                       order("id DESC")
  #   end
  #   
  #   @total = @objects.count
  #   @success = true 
  #   # render :json => { :records => @objects , :total => @objects.count, :success => true }
  # end
end
