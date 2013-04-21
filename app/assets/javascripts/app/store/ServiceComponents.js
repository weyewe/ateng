Ext.define('AM.store.ServiceComponents', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.ServiceComponent'],
  	model: 'AM.model.ServiceComponent',
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
