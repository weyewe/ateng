json.success true 
json.total @total
json.usage_options @objects do |object|
	json.id 				object.id 
 
	
	json.service_component_id object.service_component_id
	json.service_component_name object.service_component.name 
	
	json.material_usage_id object.material_usage_id
	json.material_usage_name object.material_usage.name 
	
	json.item_id object.item_id
	json.item_name object.item.name 
	
	json.quantity object.quantity 
end
