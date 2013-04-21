Ext.define('AM.view.master.Service', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.serviceProcess',
	 	layout : {
			type : 'vbox',
			align : 'stretch'
		},
		
		items : [
			{
				xtype : 'servicelist' ,
				flex : 1
			},
			// {
			// 	xtype : 'panel',
			// 	html : "This is the service component",
			// 	flex : 1 
			// }
			{
				xtype : 'servicecomponentlist',
				flex : 1 
			}
		]
});