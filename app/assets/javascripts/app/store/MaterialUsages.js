Ext.define('AM.store.MaterialUsages', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.MaterialUsage'],
  	model: 'AM.model.MaterialUsage',
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
