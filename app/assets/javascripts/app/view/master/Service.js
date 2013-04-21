Ext.define('AM.view.master.Service', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.serviceProcess',
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
						xtype : 'servicelist' ,
						flex : 1
					},
					{
						xtype : 'servicecomponentlist',
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
						xtype : 'panel' ,
						flex : 1,
						html : "Tujuan Penggunaan"
					},
					{
						xtype : 'panel',
						flex : 1 ,
						html : "Pilihan Bahan Baku"
					}
				]
			}
		]
		
		
		// items : [
		// 	{
		// 		xtype : 'servicelist' ,
		// 		flex : 1
		// 	},
		// 	{
		// 		xtype : 'servicecomponentlist',
		// 		flex : 1 
		// 	}
		// ]
});