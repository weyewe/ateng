Ext.define('AM.model.MaterialConsumption', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },

			{ name: 'service_execution_id', type: 'int' } ,


			{ name: 'sales_order_entry_id', type: 'int' } ,
			{ name: 'sellable_name', type: 'string' } ,
			
    	{ name: 'service_component_id', type: 'int' } ,
			{ name: 'service_component_name', type: 'string' } ,
			
			
			
			{ name: 'usage_option_id', type: 'int' } ,
			{ name: 'item_name', type: 'string' },
			{ name: 'quantity', type: 'int' } 
  	],

  	idProperty: 'id' ,proxy: {
			url: 'api/material_consumptions',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'material_consumptions',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { material_consumption : record.data };
				}
			}
		}
});
