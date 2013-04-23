Ext.define('AM.store.ServiceExecutions', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.ServiceExecution'],
  	model: 'AM.model.ServiceExecution',
  	// autoLoad: {start: 0, limit: this.pageSize},
		autoLoad : false, 
  	autoSync: false,
	pageSize : 10, 
	
	
		
		
	sorters : [
		{
			property	: 'id',
			direction	: 'DESC'
		}
	], 

	listeners: {

	} 
});
