Ext.define('AM.store.Services', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.Service'],
  	model: 'AM.model.Service',
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
