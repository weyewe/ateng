class Api::ServiceComponentsController < Api::BaseApiController
  
  def index
    @parent = Service.find_by_id params[:service_id]
    @objects = @parent.active_service_components.joins(:service).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = @parent.active_service_components.count
    
    render :json => { :service_components => @objects , :total => @total , :success => true }
  end

  def create
   
    @parent = Service.find_by_id params[:service_id]
    
    params[:service_component][:service_id] = params[:service_id]
    @object = ServiceComponent.create_object( params[:service_component] )  
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :service_components => [@object] , 
                        :total => @parent.active_service_components.count }  
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
    @object = ServiceComponent.find_by_id params[:id] 
    @parent = @object.service 
    
    params[:service_component][:service_id] = params[:service_id]
    @object.update_object(params[:service_component])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :service_components => [@object],
                        :total => @parent.active_service_components.count  } 
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
    @object = ServiceComponent.find(params[:id])
    @parent = @object.service 
    @object.delete_object

    if  ( not @object.persisted? )
      render :json => { :success => true, :total => @parent.active_service_components.count }  
    else
      render :json => { :success => false, :total =>@parent.active_service_components.count }  
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
  #     @objects = ServiceComponent.joins(  :service ).where{ (template_service_component.name =~ query )   & 
  #                               (is_deleted.eq false )  & 
  #                               (service.customer_id.eq customer_id)
  #                             }.
  #                       page(params[:page]).
  #                       per(params[:limit]).
  #                       order("id DESC")
  #   else
  #     @objects = ServiceComponent.joins( :service).where{ (id.eq selected_id)  & 
  #                               (is_deleted.eq false ) & 
  #                               (service.customer_id.eq customer_id)
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
