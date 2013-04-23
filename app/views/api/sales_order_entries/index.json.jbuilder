json.success true 
json.total @total
json.sales_order_entries @objects do |object|
	json.sales_order_code object.sales_order.code
	json.sales_order_id object.sales_order_id  
	json.id 				object.id 
	
	json.sellable_name 				object.sellable.name  
	json.sellable_id 				object.sellable.id
	json.quantity 				object.quantity

	json.unit_price 				object.unit_price
	json.discount 				object.discount
	json.total_price 				object.total_price
	
	json.entry_case 				object.entry_case
	json.entry_id 				object.entry_id
	
	if object.entry_case == SALES_ORDER_ENTRY_CASE[:item]
		json.employee_id 				object.employee_id
		json.employee_name 				object.employee.name
	end

	
	
	json.is_confirmed object.is_confirmed 
end
