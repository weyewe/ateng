require 'spec_helper'

describe MaterialUsage do
  before(:each) do
    #creating item
    @selling_price = "100000"
    @item_name = "Test Item"
    @commission_amount = '10000'
    @item1  = Item.create_object(  {
      :name          =>  "#{@item_name} 1" ,
      :selling_price => @selling_price,
      :commission_amount => @commission_amount 
    })
    @item1.reload
    
    @quantity1 = 10
    @quantity2 = 5
    @quantity3 = 4
    @average_cost_1 = '40000'
    @average_cost_2 = '50000'
    @average_cost_3 = '100000'
    @stock_migration1 = StockMigration.create_object({
      :item_id => @item1.id, 
      :quantity => @quantity1 , 
      :average_cost => @average_cost_1
    })
    @stock_entry1 = @stock_migration1.stock_entry
    
    
    #creating service 
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
    
    it 'should not have first_available_option' do
      @material_usage.first_available_option.should be_nil 
    end
    
    context "creating usage_option" do 
      before(:each) do
        @mu_quantity = 2 
        @usage_option = UsageOption.create_object({
          :service_component_id => @service_component.id , 
          :material_usage_id    => @material_usage.id ,
          :item_id              => @item1.id , 
          :quantity             => @mu_quantity
        })
      end
      
      it 'should create usage_option' do
        @usage_option.should be_valid 
      end
      
      it 'should extract the usage option' do
        @material_usage.first_available_option.should be_valid 
        @material_usage.first_available_option.id.should == @usage_option.id 
      end
    end
    
  end
  
end
