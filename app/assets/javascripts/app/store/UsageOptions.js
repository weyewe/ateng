Ext.define('AM.store.UsageOptions', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.UsageOption'],
  	model: 'AM.model.UsageOption',
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
