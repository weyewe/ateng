Ext.define('AM.model.SalesOrderEntry', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,
			{ name: 'sales_order_code', type: 'string' },
			{ name: 'sales_order_id', type: 'int' },
			{ name: 'sellable_name', type: 'string'},
			{ name: 'sellable_id', type: 'int'},
			
			{ name: 'entry_case', type: 'int'},
			{ name: 'entry_id', type: 'int'},
			
			{ name: 'quantity',type: 'int'},
			{ name: 'discount',type: 'string'},
			{ name: 'employee_id', type: 'int'},
			{ name: 'employee_name', type: 'string'},
			
			{ name: 'unit_price',type: 'string'},
			{ name: 'total_price',type: 'string'}
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
