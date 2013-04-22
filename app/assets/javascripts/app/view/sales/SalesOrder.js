Ext.define('AM.view.sales.SalesOrder', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.salesorderProcess',
	 
		layout : {
			type : 'vbox',
			align : 'stretch'
		},
		
		items : [
			// {
			// 	type : 'panel',
			// 	html : 'this is the sales order'
			// }
			{
				xtype : 'salesorderlist' ,
				flex : 1  
			},
			{
				xtype : 'salesorderentrylist',
				flex : 1 
			}
		]
});