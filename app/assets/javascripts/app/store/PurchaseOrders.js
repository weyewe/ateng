Ext.define('AM.store.PurchaseOrders', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.PurchaseOrder'],
  	model: 'AM.model.PurchaseOrder',
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
