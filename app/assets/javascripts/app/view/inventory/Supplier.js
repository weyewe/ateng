Ext.define('AM.view.inventory.Supplier', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.supplierProcess',
	 
		
		items : [
			{
				xtype : 'supplierlist' ,
				flex : 1 
			} 
		]
});