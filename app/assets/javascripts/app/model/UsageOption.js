Ext.define('AM.model.UsageOption', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
			{ name: 'service_component_id', type: 'int' },
			{ name: 'service_component_name', type: 'string' },
			
			{ name: 'material_usage_id', type: 'int' },
			{ name: 'material_usage_name', type: 'string' },
			
			{ name: 'item_id', type: 'int' },
			{ name: 'item_name', type: 'string' },
			{ name: 'quantity', type: 'int' }
  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/usage_options',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'usage_options',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { usage_option : record.data };
				}
			}
		}
	
  
});
