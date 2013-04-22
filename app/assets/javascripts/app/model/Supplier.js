Ext.define('AM.model.Supplier', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'name', type: 'string' } 
	 
  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/suppliers',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'suppliers',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { supplier : record.data };
				}
			}
		}
	
  
});
