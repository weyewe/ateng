Ext.define('AM.model.PurchaseOrderEntry', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,
			{ name: 'purchase_order_code', type: 'string' },
			{ name: 'item_name', type: 'string'},
			{ name: 'quantity',type: 'int'},
			{	name: 'item_id', type: 'int'}
  	],

	 

  	idProperty: 'id' ,proxy: {
			url: 'api/purchase_order_entries',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'purchase_order_entries',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { purchase_order_entry : record.data };
				}
			}
		}
	
  
});
