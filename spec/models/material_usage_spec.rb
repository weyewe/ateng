require 'spec_helper'

describe MaterialUsage do
  before(:each) do
    @service = Service.create_object({
      :name => 'First Service',
      :selling_price => '120000'
    })
    
    @name = 'service component'
    @commission_amount = '12000'
    @service_component = ServiceComponent.create_object({
      :name => @name ,
      :service_id => @service.id ,
      :commission_amount => @commission_amount
    })
  end
  
  it 'should create material_usage' do
    @material_usage = MaterialUsage.create_object({
      :name => "Name",
      :service_component_id => @service_component.id ,
      :service_id => @service.id 
    })
    
    @material_usage.should be_valid 
  end
  
  it 'requires service_component_id  and name' do
    @material_usage = MaterialUsage.create_object({
      :name => "Name",
      :service_component_id => nil  ,
      :service_id => @service.id
    })
    
    @material_usage.should_not be_valid 
    
    @material_usage = MaterialUsage.create_object({
      :name => "",
      :service_component_id => @service_component.id ,
      :service_id => @service.id  
    })
    
    @material_usage.should_not be_valid
  end
  
  context "update material_usage" do
    before(:each) do
      @material_usage = MaterialUsage.create_object({
        :name => "Name",
        :service_component_id => @service_component.id ,
        :service_id => @service.id
      })
      
      @service_component2  = @service_component = ServiceComponent.create_object({
        :name => "new name" ,
        :service_id => @service.id ,
        :commission_amount => '100000'
      })
    end
    
    it 'should update the service_component' do
      
      @material_usage.update_object({
        :name => "second shite",
        :service_component_id => @service_component2.id,
        :service_id => @service.id
      })
      @material_usage.should be_valid 
      @material_usage.service_component_id.should == @service_component2.id 
    end
    
  end
  
end
