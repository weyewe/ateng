Ext.define('AM.model.PurchaseOrder', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,
			{ name: 'supplier_id', type: 'int' },
			{ name: 'supplier_name', type: 'string'},
			{ name: 'is_confirmed',type: 'boolean', defaultValue: false } 
  	],

	 

  	idProperty: 'id' ,proxy: {
			url: 'api/purchase_orders',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'purchase_orders',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { purchase_order : record.data };
				}
			}
		}
	
  
});
