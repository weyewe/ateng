json.success true 
json.total @total
json.material_consumptions @objects do |object|
	json.id 				object.id 
 

	json.sales_order_entry_id 	object.sales_order_entry.id
	json.sellable_name 					object.sales_order_entry.sellable.name 

	json.service_component_id 	object.usage_option.service_component_id
	json.service_component_name object.usage_option.service_component.name 

	json.usage_option_id 				object.usage_option_id
	json.item_name 							object.usage_option.item.name 

	json.quantity 							object.usage_option.quantity

	
end
