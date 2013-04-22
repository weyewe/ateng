Ext.define('AM.view.inventory.item.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.itemlist',

  	store: 'Items', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'Name', dataIndex: 'name'},
			{ header: 'Komisi Penjualan',  dataIndex: 'commission_amount',  flex: 1 , sortable: false} ,
			{ header: 'Harga Jual',  dataIndex: 'selling_price',  flex: 1 , sortable: false} ,
			{ header: 'Ready',  dataIndex: 'ready',  flex: 1 , sortable: false} ,
			{ header: 'Menunggu Penerimaan',  dataIndex: 'pending_receival',  flex: 1 , sortable: false} ,
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add Item',
			action: 'addObject'
		});

		this.editObjectButton = new Ext.Button({
			text: 'Edit Item',
			action: 'editObject',
			disabled: true
		});

		this.deleteObjectButton = new Ext.Button({
			text: 'Delete Item',
			action: 'deleteObject',
			disabled: true
		});
		
		// this.filler = new Ext.toolbar.FillView({});  
		
		this.searchField = new Ext.form.field.Text({
			name: 'searchField',
			hideLabel: true,
			width: 200,
			emptyText : "Search",
			checkChangeBuffer: 300
		}); 




		// this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton, '->', this.searchObjectButton ];
		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton,  this.searchField ];
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
		this.editObjectButton.enable();
		this.deleteObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
	}
});