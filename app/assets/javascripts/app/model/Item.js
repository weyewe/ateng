Ext.define('AM.model.Item', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'name', type: 'string' },
			{ name: 'commission_amount', type: 'string' },
			{ name: 'selling_price', type: 'string' },
			{ name: 'ready', type: 'int' },
			{ name: 'pending_receival', type: 'int' },

  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/items',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'items',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { item : record.data };
				}
			}
		}
	
  
});
