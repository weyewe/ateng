json.success true 
json.total @total
json.records @objects do |object|
	json.id 														object.id
	
	json.details 												object.details
	json.quantity 				object.quantity
	json.item_name 				object.item.name
	json.item_id					object.item_id

end
