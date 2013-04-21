Ext.define('AM.model.ServiceComponent', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
			{ name: 'service_id', type: 'int' } ,
    	{ name: 'name', type: 'string' } ,
			{ name: 'commission_amount', type: 'string' } 
  	],

  	idProperty: 'id' ,proxy: {
			url: 'api/service_components',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'service_components',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { service_component : record.data };
				}
			}
		}
});
