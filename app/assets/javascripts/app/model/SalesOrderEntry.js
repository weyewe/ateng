Ext.define('AM.model.SalesOrderEntry', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,
			{ name: 'sales_order_code', type: 'string' },
			{ name: 'sales_order_id', type: 'int' },
			{ name: 'item_name', type: 'string'},
			{ name: 'item_id', type: 'id'},
			{ name: 'quantity',type: 'int'}
  	],

  	idProperty: 'id' ,proxy: {
			url: 'api/sales_order_entries',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'sales_order_entries',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { sales_order_entry : record.data };
				}
			}
		}
	
  
});
