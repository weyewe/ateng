class Api::StockMigrationsController < Api::BaseApiController
  
  def index
    @objects = StockMigration.where(:item_id => params[:item_id]).page(params[:page]).per(params[:limit]).order("id DESC")
    render :json => { :stock_migrations => @objects , :total => StockMigration.active_objects.count, :success => true }
  end

  def create
    @object = StockMigration.create_object(   params[:stock_migration] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :stock_migrations => [@object] , 
                        :total => StockMigration.active_objects.count }  
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
    
    @object = StockMigration.find_by_id params[:id] 
    @object.update_object(   params[:stock_migration])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :stock_migrations => [@object],
                        :total => StockMigration.active_objects.count  } 
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

  # def destroy
  #   @object = StockMigration.find(params[:id])
  #   @object.delete(current_user)
  # 
  #   if @object.is_deleted
  #     render :json => { :success => true, :total => StockMigration.active_objects.count }  
  #   else
  #     render :json => { :success => false, :total => StockMigration.active_objects.count }  
  #   end
  # end
end
