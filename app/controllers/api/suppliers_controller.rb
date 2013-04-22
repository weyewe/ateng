class Api::SuppliersController < Api::BaseApiController
  
  def index
    @objects = Supplier.active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
    render :json => { :suppliers => @objects , :total => Supplier.active_objects.count, :success => true }
  end

  def create
    @object = Supplier.new(params[:supplier])
 
    if @object.save
      render :json => { :success => true, 
                        :suppliers => [@object] , 
                        :total => Supplier.active_objects.count }  
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
    @object = Supplier.find(params[:id])
    
    if @object.update_attributes(params[:supplier])
      render :json => { :success => true,   
                        :suppliers => [@object],
                        :total => Supplier.active_objects.count  } 
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
    @object = Supplier.find(params[:id])
    @object.delete(current_user)

    if @object.is_deleted
      render :json => { :success => true, :total => Supplier.active_objects.count }  
    else
      render :json => { :success => false, :total => Supplier.active_objects.count }  
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
      @objects = Supplier.where{ (name =~ query)   & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = Supplier.where{ (id.eq selected_id)  & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    end
    
    
    render :json => { :records => @objects , :total => @objects.count, :success => true }
  end
end
