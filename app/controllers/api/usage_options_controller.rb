class Api::UsageOptionsController < Api::BaseApiController
  
  def index
    @parent = MaterialUsage.find_by_id params[:material_usage_id]
    @objects = @parent.active_usage_options.joins(:material_usage, :item ).
                page(params[:page]).
                per(params[:limit]).order("id DESC")
    @total = @parent.active_usage_options.count
    
    # render :json => { :usage_options => @objects , :total => @total , :success => true }
  end

  def create
   
    @parent = MaterialUsage.find_by_id params[:material_usage_id]
    
    params[:usage_option][:material_usage_id] = params[:material_usage_id]
    @object = UsageOption.create_object( params[:usage_option] )  
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :usage_options => [@object] , 
                        :total => @parent.active_usage_options.count }  
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
    @object = UsageOption.find_by_id params[:id] 
    @parent = @object.material_usage 
    
    params[:usage_option][:material_usage_id] = params[:material_usage_id]
    @object.update_object(params[:usage_option])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :usage_options => [@object],
                        :total => @parent.active_usage_options.count  } 
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
    @object = UsageOption.find(params[:id])
    @parent = @object.material_usage 
    @object.delete_object

    if  ( not @object.persisted? )
      render :json => { :success => true, :total => @parent.active_usage_options.count }  
    else
      render :json => { :success => false, :total =>@parent.active_usage_options.count,
        :message => {
          :errors => extjs_error_format( @object.errors )  
        } }  
    end
  end
  
  def search
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    
    selected_service_id = params[:service_id]
    valid_service_component_id_list = ServiceComponent.
                        where(:service_id => selected_service_id, :is_deleted => false ).
                        map{|x| x.id}
    
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    if  selected_id.nil?
      @objects = UsageOption.joins(  :material_usage , :item).where{ (item.name =~ query )   & 
                                (material_usage.service_id.eq selected_service_id) & 
                                (material_usage.service_component_id.in valid_service_component_id_list ) 
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = UsageOption.joins( :material_usage, :item ).where{ (id.eq selected_id)  & 
                                (material_usage.service_id.eq selected_service_id) & 
                                (material_usage.service_component_id.in valid_service_component_id_list )
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
