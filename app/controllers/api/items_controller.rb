class Api::ItemsController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = Item.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch ) | 
          (supplier_code =~ livesearch) | 
          (customer_code =~ livesearch)
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = Item.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch ) | 
          (supplier_code =~ livesearch) | 
          (customer_code =~ livesearch)
        )
      }.count
    else
      @objects = Item.active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
      @total = Item.active_objects.count
    end
    
    
    render :json => { :items => @objects , :total =>  @total , :success => true }
  end

  def create
    @object = Item.create_by_employee(current_user,  params[:item] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :items => [@object] , 
                        :total => Item.active_objects.count }  
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
    
    @object = Item.find_by_id params[:id] 
    @object.update_by_employee(current_user,  params[:item])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :items => [@object],
                        :total => Item.active_objects.count  } 
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
    @object = Item.find(params[:id])
    @object.delete(current_user)

    if @object.is_deleted
      render :json => { :success => true, :total => Item.active_objects.count }  
    else
      render :json => { :success => false, :total => Item.active_objects.count }  
    end
  end
  
  def search
    
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    
    query = "%#{search_params}%"
    
    
    # search_params = params[:query]
    # query = '%' + search_params + '%'
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    # @objects = Item.where{ (name =~ query)  & (is_deleted.eq false) }.
    #                   page(params[:page]).
    #                   per(params[:limit]).
    #                   order("id DESC")
    
    if  selected_id.nil?
      @objects = Item.where{ (name =~ query)   & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = Item.where{ (id.eq selected_id)  & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    end
    
    
    
    render :json => { :records => @objects , :total => @objects.count, :success => true }
  end
end
