require 'spec_helper'

describe UsageOption do
  before(:each) do
    @selling_price = "100000"
    @item_name = "Test Item"
    @commission_amount = '10000'
    @item1  = Item.create_object(  {
      :name          =>  "#{@item_name} 1" ,
      :selling_price => @selling_price,
      :commission_amount => @commission_amount
    })
    
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
    
    @material_usage = MaterialUsage.create_object({
      :name => "Name",
      :service_component_id => @service_component.id ,
      :service_id => @service.id
    })
  end
  
  it 'should create usage_option' do
    @usage_option = UsageOption.create_object({
      :service_component_id => @service_component.id , 
      :material_usage_id    => @material_usage.id ,
      :item_id              => @item1.id , 
      :quantity             => 10
    })
    @usage_option.should be_valid 
  end
  
  context "post create usage option" do
    before(:each) do
      @quantity = 1 
      @usage_option = UsageOption.create_object({
        :service_component_id => @service_component.id , 
        :material_usage_id    => @material_usage.id ,
        :item_id              => @item1.id , 
        :quantity             => @quantity
      })
    end
    
    it 'should create usage_option' do
      @usage_option.should be_valid 
    end
    
    it 'should be allowed to update usage_option' do
      @new_quantity = @quantity + 5 
      @usage_option.update_object({
        :service_component_id => @service_component.id , 
        :material_usage_id    => @material_usage.id ,
        :item_id              => @item1.id , 
        :quantity             => @new_quantity
      })
      
      @usage_option.should be_valid 
      @usage_option.quantity.should == @new_quantity 
    end
  end
end
