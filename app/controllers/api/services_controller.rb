class Api::ServicesController < Api::BaseApiController
  
  def index
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = Service.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = Service.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch )
        )
      }.count
    else
      @objects = Service.active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
      @total = Service.active_objects.count
    end
    
    render :json => { :services => @objects , :total => @total , :success => true }
  end

  def create
    @object = Service.create_object( params[:service] )
 
    if @object.valid? 
      render :json => { :success => true, 
                        :services => [@object] , 
                        :total => Service.active_objects.count }  
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors ) 
          # :errors => {
          #   :name => "Nama tidak boleh bombastic"
          # }
        }
      }
      
      render :json => msg                         
    end
  end

  def update
    @object = Service.find(params[:id])
    @object.update_object(params[:service])
    if @object.errors.size ==  0 
      render :json => { :success => true,   
                        :services => [@object],
                        :total => Service.active_objects.count  } 
    else
      msg = {
        :success => false, 
        :message => {
          :errors => {
            :name => "Nama tidak boleh kosong"
          }
        }
      }
      
      render :json => msg 
    end
  end

  def destroy
    @object = Service.find(params[:id])
    @object.delete_object

    if @object.is_deleted
      render :json => { :success => true, :total => Service.active_objects.count }  
    else
      render :json => { :success => false, :total => Service.active_objects.count }  
    end
  end
  
  def search
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    if  selected_id.nil?  
      @objects = Service.where{  (name =~ query)   & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = Service.where{ (id.eq selected_id)  & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    end
    
    
    render :json => { :records => @objects , :total => @objects.count, :success => true }
  end
end
