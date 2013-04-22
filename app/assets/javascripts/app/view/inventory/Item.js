Ext.define('AM.view.inventory.Item', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.itemProcess',
	 	layout : {
			type : 'vbox',
			align : 'stretch'
		},
		
		
		items : [
			{
				xtype : 'itemlist' ,
				flex : 1 
			} ,
			{
				xtype : 'stockmigrationlist' ,
				flex : 1
			}
		]
});