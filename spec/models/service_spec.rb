require 'spec_helper'

describe Service do
  it 'should create service' do
    @service = Service.create_object({
      :name => 'First Service',
      :selling_price => '120000'
    })
    
    @service.should be_valid 
  end
  
  it 'should have name' do
    @service = Service.create_object({
      :name => '',
      :selling_price => @selling_price
    })
    
    @service.should_not be_valid 
  end
  
  it 'should have more than 0 selling price' do
    @service = Service.create_object({
      :name => 'test',
      :selling_price => '0'
    })
    
    @service.should_not be_valid 
    
    @service = Service.create_object({
      :name => 'test',
      :selling_price => '-5000'
    })
    
    @service.should_not be_valid
  end
  
  context "post service creation" do
    before(:each) do
      @service_name = 'First Service'
      @selling_price = '120000'
      @service = Service.create_object({
        :name => @service_name,
        :selling_price => @selling_price
      })
    end
    
    it 'should not create duplicate name' do
      @new_service = Service.create_object({
        :name => @service_name,
        :selling_price => @selling_price
      })
      @new_service.should_not be_valid 
    end
    
    it 'should be destroyed if there is no sales_order' do
      service_id = @service.id 
      @service.delete_object
      
      Service.find_by_id(service_id).should be_nil
    end
    
    context "post sales order creation => can't hard delete service" do
      before(:each) do
        # create sales order
      end
      
      it 'can only be soft-deleted'
      
    end
    
  end
  
end
