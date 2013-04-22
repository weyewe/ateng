Ext.define('AM.view.inventory.PurchaseOrder', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.purchaseorderProcess',
	 
		layout : {
			type : 'vbox',
			align : 'stretch'
		},
		
		items : [
			{
				xtype : 'purchaseorderlist' ,
				flex : 1  
			},
			{
				xtype : 'purchaseorderentrylist',
				flex : 1 
			}
		]
});