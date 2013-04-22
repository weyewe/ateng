Ext.define('AM.store.StockMigrations', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.StockMigration'],
  	model: 'AM.model.StockMigration',
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
