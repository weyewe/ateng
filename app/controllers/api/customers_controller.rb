class Api::CustomersController < Api::BaseApiController
  
  def index
    @objects = Customer.active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
    render :json => { :customers => @objects , :total => Customer.active_objects.count, :success => true }
  end

  def create
    # @object = Customer.new(params[:customer])
 
    @object = Customer.create_object( params[:customer] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :customers => [@object] , 
                        :total => Customer.active_objects.count }  
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
    @object = Customer.find(params[:id])
    
    @object.update_object( params[:customer] )
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :customers => [@object],
                        :total => Customer.active_objects.count  } 
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
    @object = Customer.find(params[:id])
    @object.delete_object 

    if @object.is_deleted
      render :json => { :success => true, :total => Customer.active_objects.count }  
    else
      render :json => { :success => false, :total => Customer.active_objects.count }  
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
      @objects = Customer.where{ (name =~ query)   & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = Customer.where{ (id.eq selected_id)  & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    end
    
    
    render :json => { :records => @objects , :total => @objects.count, :success => true }
  end
end
