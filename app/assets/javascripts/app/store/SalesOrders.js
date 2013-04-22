Ext.define('AM.store.SalesOrders', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.SalesOrder'],
  	model: 'AM.model.SalesOrder',
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
