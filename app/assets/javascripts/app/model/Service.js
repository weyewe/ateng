Ext.define('AM.model.Service', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'name', type: 'string' } ,
			{ name: 'selling_price', type: 'string' } 
  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/services',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'services',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { service : record.data };
				}
			}
		}
	
  
});
