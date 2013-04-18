require 'spec_helper'

describe ServiceComponent do
  before(:each) do
    @service = Service.create_object({
      :name => 'First Service',
      :selling_price => '120000'
    })
  end
  
  it 'should create service_component' do
    name = 'service component'
    commission_amount = '12000'
    service_component = ServiceComponent.create_object({
      :name => name ,
      :service_id => @service.id ,
      :commission_amount => commission_amount
    })
    
    service_component.should be_valid
    @service.reload
    @service.active_service_components.count.should == 1 
  end
  
  
   
  
  context "post service component creation" do
    before(:each ) do
      @name = 'service component'
      @commission_amount = '12000'
      @service_component = ServiceComponent.create_object({
        :name => @name ,
        :service_id => @service.id ,
        :commission_amount => @commission_amount
      })
    end
    
    it 'should create service component' do
      @service_component.should be_valid 
    end
    
    
    it 'should be updatable' do 
      new_name = "new Name"
      new_commission_amount = '150000'
      @service_component.update_object({
        :name => new_name,
        :service_id => @service.id , 
        :commission_amount => new_commission_amount 
      })
      
      @service_component.should be_valid 
    end
    
    
  end
  
end
