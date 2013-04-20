Ext.define('AM.view.Header', {
    extend: 'Ext.toolbar.Toolbar',
    alias : 'widget.appHeader',
    require : [
			'AM.view.header.EditPassword'
		],
    
    height: 53,

		
    
    items: [
        {
            text: 'haha',
            // iconCls: 'book',
            action: 'panelUtama'  
        },
				'->',
				{
					text: "Options",
					itemId : 'optionsMenu',
					menu: [
						{
							action: 'editPassword',
							text: "Ganti Password",
							listeners: {
								click: function() {
									var editPasswordWindow = Ext.create('AM.view.header.EditPassword');
									editPasswordWindow.show();

								}
							}
						},
						{
							text: "Ganti Profile"
						}
					]
				},
				'-',
				{
            text: 'Logout',
            // iconCls: 'book',
            action: 'logoutUser'  
        }
    ]
});
