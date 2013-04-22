Ext.define('AM.store.PurchaseOrderEntries', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.PurchaseOrderEntry'],
  	model: 'AM.model.PurchaseOrderEntry',
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
