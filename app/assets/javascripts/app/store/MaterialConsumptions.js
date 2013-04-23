Ext.define('AM.store.MaterialConsumptions', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.MaterialConsumption'],
  	model: 'AM.model.MaterialConsumption',
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
