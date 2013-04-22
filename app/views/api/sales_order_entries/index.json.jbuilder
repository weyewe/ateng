json.success true 
json.total @total
json.sales_order_entries @objects do |object|
	json.sales_order_code object.sales_order.code 
	json.sales_order_id object.sales_order_id  
	json.code 			object.code
	json.id 				object.id 
	
	json.sellable_name 				object.sellable.name  
	json.sellable_id 				object.sellable.id
	json.quantity 				object.quantity
	
	json.is_confirmed object.is_confirmed 
end
