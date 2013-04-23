class Api::UsageOptionsController < Api::BaseApiController
  
  def index
    @parent = MaterialUsage.find_by_id params[:material_usage_id]
    @objects = @parent.active_usage_options.joins(:material_usage, :item, :service_component).
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
      render :json => { :success => false, :total =>@parent.active_usage_options.count }  
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
      @objects = UsageOption.joins(  :material_usage , :item).where{ (item.name =~ query )   & 
                                (is_deleted.eq false )  & 
                                (material_usage.customer_id.eq customer_id)
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = UsageOption.joins( :material_usage).where{ (id.eq selected_id)  & 
                                (is_deleted.eq false ) & 
                                (material_usage.customer_id.eq customer_id)
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
