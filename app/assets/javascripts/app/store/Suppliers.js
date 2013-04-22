Ext.define('AM.store.Suppliers', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.Supplier'],
  	model: 'AM.model.Supplier',
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
