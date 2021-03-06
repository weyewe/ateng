Ext.define('AM.view.sales.salesorder.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.salesorderlist',

  	store: 'SalesOrders', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'ID', dataIndex: 'id'},
			{ header: 'Code',  dataIndex: 'code',  flex: 1 , sortable: false},
			{ header: 'Customer',  dataIndex: 'customer_name',  flex: 1 , sortable: false},
			{ header: 'Confirmed?',  dataIndex: 'is_confirmed',  flex: 1 , sortable: false},
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add Sales Order',
			action: 'addObject'
		});

		this.editObjectButton = new Ext.Button({
			text: 'Edit Sales Order',
			action: 'editObject',
			disabled: true
		});

		this.deleteObjectButton = new Ext.Button({
			text: 'Delete Sales Order',
			action: 'deleteObject',
			disabled: true
		});
		
		this.confirmObjectButton = new Ext.Button({
			text: 'Confirm',
			action: 'confirmObject',
			disabled: true
		});
		
		
		// this.startDateMenu = Ext.create('Ext.menu.DatePicker', {});
		// 
		// this.startDateButton = new Ext.Button({
		// 	text: 'Mulai: ',
		// 	action: 'startDateObject',
		// 	disabled: true,
		// 	menu: this.startDateMenu
		// });
		// 
		// this.endDateMenu = Ext.create('Ext.menu.DatePicker', {});
		// 
		// this.endDateButton = new Ext.Button({
		// 	text: 'Selesai: ',
		// 	action: 'endDateObject',
		// 	disabled: true,
		// 	menu: this.endDateMenu
		// });
		// 
		// this.toggleSearchDateRangeButton = new Ext.Button({
		// 	text: 'DateRange',
		// 	action: 'dateRangeToggle',
		// 	disabled: false,
		// 	pressed : false,
		// 	enableToggle: true 
		// });
		// 
		 
		



		// this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton, this.confirmObjectButton, '-', 
		// 						this.startDateButton , this.endDateButton, this.toggleSearchDateRangeButton];
	
		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton, this.confirmObjectButton ];
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
		this.confirmObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
		this.confirmObjectButton.disable();
	}
});
