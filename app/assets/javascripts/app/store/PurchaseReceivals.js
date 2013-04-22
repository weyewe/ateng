Ext.define('AM.store.PurchaseReceivals', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.PurchaseReceival'],
  	model: 'AM.model.PurchaseReceival',
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
