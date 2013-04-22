Ext.define('AM.model.PurchaseReceivalEntry', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,
			{ name: 'purchase_receival_code', type: 'string' },
			{ name: 'purchase_receival_id', type: 'int' },
			{ name: 'item_name', type: 'string'},
			
			// purchase order entry  related 
			{ name: 'quantity',type: 'int'}, 
			{ name: 'purchase_order_entry_id', type: 'int'},
			{ name: 'purchase_order_code', type: 'string'},
			{ name: 'purchase_order_entry_code', type: 'string'},
  	],

	 

  	idProperty: 'id' ,proxy: {
			url: 'api/purchase_receival_entries',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'purchase_receival_entries',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { purchase_receival_entry : record.data };
				}
			}
		}
	
  
});
