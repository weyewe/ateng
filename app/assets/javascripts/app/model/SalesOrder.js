Ext.define('AM.model.SalesOrder', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,
			{ name: 'customer_id', type: 'int' },
			{ name: 'customer_name', type: 'string'},
			{ name: 'is_confirmed',type: 'boolean', defaultValue: false } 
  	],

	 

  	idProperty: 'id' ,proxy: {
			url: 'api/sales_orders',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'sales_orders',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { sales_order : record.data };
				}
			}
		}
	
  
});
