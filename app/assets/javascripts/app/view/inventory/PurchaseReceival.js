Ext.define('AM.view.inventory.PurchaseReceival', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.purchasereceivalProcess',
	 
		layout : {
			type : 'vbox',
			align : 'stretch'
		},
		
		items : [
			{
				xtype : 'purchasereceivallist' ,
				flex : 1  
			},
			{
				xtype : 'purchasereceivalentrylist',
				flex : 1 
			}
		]
});