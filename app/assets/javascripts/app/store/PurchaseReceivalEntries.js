Ext.define('AM.store.PurchaseReceivalEntries', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.PurchaseReceivalEntry'],
  	model: 'AM.model.PurchaseReceivalEntry',
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
