Ext.define('AM.store.SalesOrderEntries', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.SalesOrderEntry'],
  	model: 'AM.model.SalesOrderEntry',
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
