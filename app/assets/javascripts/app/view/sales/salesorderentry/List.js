Ext.define('AM.view.sales.salesorderentry.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.salesorderentrylist',

  	store: 'SalesOrderEntries', 
 

	initComponent: function() {
		this.columns = [
		
	 
			
		
			{
				xtype : 'templatecolumn',
				text : "Barang/Jasa",
				flex : 1,
				dataIndex : 'sellable_name',
				tpl : '{sellable_name}'  
			}, 
			
			{
				xtype : 'templatecolumn',
				text : "Jumlah",
				flex : 1,
				dataIndex : 'quantity',
				tpl : '{quantity}'  
				
			},
			{
				xtype : 'templatecolumn',
				text : "Harga Satuan",
				flex : 1,
				dataIndex : 'name',
				tpl : '{unit_price}' 
				
			},
			{
				xtype : 'templatecolumn',
				text : "Diskon",
				flex : 1,
				dataIndex : 'discount',
				tpl : '<b>{discount}</b>%' 
			},
			{
				xtype : 'templatecolumn',
				text : "Total",
				flex : 1,
				dataIndex : 'total_price',
				tpl : '{total_price}' 
			},
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add Item',
			action: 'addObject',
			disabled : true 
		});
		
		this.addServiceObjectButton = new Ext.Button({
			text: 'Add Service',
			action: 'addServiceObject',
			disabled : true 
		});

		this.editObjectButton = new Ext.Button({
			text: 'Edit',
			action: 'editObject',
			disabled: true
		});
		
		this.deleteObjectButton = new Ext.Button({
			text: 'Delete',
			action: 'deleteObject',
			disabled: true
		});

	 
 



		this.tbar = [this.addObjectButton, this.addServiceObjectButton, this.editObjectButton, this.deleteObjectButton ];
		this.bbar = Ext.create("Ext.PagingToolbar", {
			store	: this.store, 
			displayInfo: true,
			displayMsg: 'Displaying topics {0} - {1} of {2}',
			emptyMsg: "No topics to display" 
		});

		this.callParent(arguments);
	},
 
	loadMask	: true,
	
	getSelectedObject: function() {
		return this.getSelectionModel().getSelection()[0];
	},

	enableRecordButtons: function() {
		this.addObjectButton.enable();
		this.addServiceObjectButton.enable();
		this.editObjectButton.enable();
		this.deleteObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.addObjectButton.disable();
		this.addServiceObjectButton.disable();
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
	},
	
	setObjectTitle : function(record){
		this.setTitle("Sales Order: " + record.get("code"));
	}
});
