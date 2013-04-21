Ext.define('AM.model.MaterialUsage', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
			{ name: 'service_component_id', type: 'int' } ,
    	{ name: 'name', type: 'string' } 
  	],

  	idProperty: 'id' ,proxy: {
			url: 'api/material_usages',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'material_usages',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { material_usage : record.data };
				}
			}
		}
});
