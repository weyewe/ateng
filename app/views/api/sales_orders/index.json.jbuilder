json.success true 
json.total @total
json.sales_orders @objects do |object|
	json.code 			object.code
	json.customer_name object.customer.name 
	json.customer_id   object.customer_id 
	json.id 				object.id 
	json.is_confirmed object.is_confirmed 
end
