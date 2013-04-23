Ext.define('AM.model.ServiceExecution', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
			{ name: 'sales_order_entry_id', type: 'int' } ,
			{ name: 'sellable_name', type: 'string' } ,
			
    	{ name: 'service_component_id', type: 'int' } ,
			{ name: 'service_component_name', type: 'string' } ,
			
			{ name: 'employee_id', type: 'int' } ,
			{ name: 'employee_name', type: 'string' } 
  	],

  	idProperty: 'id' ,proxy: {
			url: 'api/service_executions',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'service_executions',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { service_execution : record.data };
				}
			}
		}
});
