Ext.define('AM.view.sales.SalesOrder', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.salesorderProcess',
	 
		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		
		
		items : [
			{
				xtype: 'container',
				flex: 1 , 
				layout : {
					type : 'vbox',
					align : 'stretch'
				},
				items: [
					{
						xtype : 'salesorderlist' ,
						flex : 1
					},
					{
						xtype : 'salesorderentrylist',
						flex : 1 
					}
				]
			},
			
			{
				xtype: 'container',
				flex : 1 , 
				// title : "Penggunaan Bahan Baku",
				padding: '0 0 0 10',
				layout : {
					type : 'vbox',
					align : 'stretch'
				},
				items: [
				
				
					{
						xtype : 'serviceexecutionlist',
						flex : 1  
					},
					
					{
						xtype : 'materialconsumptionlist',
						flex : 1  
					},
					
					
					// {
					// 	xtype : 'panel' ,
					// 	flex : 1,
					// 	html : "Jenis Bahan"
					// },
					// {
					// 	xtype : 'panel',
					// 	flex : 1 ,
					// 	html : "Pilihan Item"
					// }
				]
			}
		]
		
		
		
		// layout : {
		// 	type : 'hbox',
		// 	align : 'stretch'
		// },
		// 
		// items : [
		// 
		// 	{
		// 		xtype : 'salesorderlist' ,
		// 		flex : 1  
		// 	},
		// 	{
		// 		xtype : 'salesorderentrylist',
		// 		flex : 1 
		// 	}
		// ]
});