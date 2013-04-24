Ext.define('AM.controller.SalesOrders', {
  extend: 'Ext.app.Controller',

  stores: ['SalesOrders'],
  models: ['SalesOrder'],

  views: [
    'sales.salesorder.List',
    'sales.salesorder.Form',
		'sales.salesorderentry.List'
  ],

  refs: [
		{
			ref: 'list',
			selector: 'salesorderlist'
		},
		{
			ref : 'salesOrderEntryList',
			selector : 'salesorderentrylist'
		},
		{
			ref: 'viewport',
			selector: 'vp'
		},
		
		// {
		// 	ref : 'dateRangeToggler',
		// 	selector: 'salesorderlist button[action=dateRangeToggle]'
		// },
		// 
		// {
		// 	ref : 'startDatePicker',
		// 	selector: 'salesorderlist button[action=startDateObject] datepicker'
		// },
		// {
		// 	ref : 'endDatePicker',
		// 	selector: 'salesorderlist button[action=endDateObject] datepicker'
		// }
	],

  init: function() {
    this.control({
      'salesorderlist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList
      },
      'salesorderform button[action=save]': {
        click: this.updateObject
      },
      'salesorderlist button[action=addObject]': {
        click: this.addObject
      },
      'salesorderlist button[action=editObject]': {
        click: this.editObject
      },
      'salesorderlist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'salesorderlist button[action=confirmObject]': {
        click: this.confirmObject
      },

			// 'salesorderlist button[action=dateRangeToggle]' : {
			// 	toggle : this.toggleSearchDateRange
			// },
			// 'salesorderlist button[action=startDateObject] datepicker': {
			//         select: this.selectedStartDate
			//       },
			// 
			// 'salesorderlist button[action=endDateObject] datepicker': {
			//         select: this.selectedEndDate
			//       },


    });
  },

	// toggleSearchDateRange : function(btn, pressed ) {
	// 	console.log("the pressed: " + pressed);
	// 	
	// 	this.getList().endDateButton.setDisabled( false ) ;
	// 	this.getList().startDateButton.setDisabled( false ) ;
	// },
	// 
	// selectedStartDate : function(datepicker, date ){
	// 	// Ext.Msg.alert('Date Selected', 'You selected ' + Ext.Date.format(date, 'M j, Y'));
	// 	var selectedDate = Ext.Date.format(date, 'M j, Y');
	// 	datepicker.up('button').setText( selectedDate );
	// },
	// 
	// selectedEndDate : function(datepicker, date ){
	// 	// Ext.Msg.alert('Date Selected', 'You selected ' + Ext.Date.format(date, 'M j, Y'));
	// 	var selectedDate = Ext.Date.format(date, 'M j, Y');
	// 	datepicker.up('button').setText( selectedDate );
	// },

	confirmObject: function(){
		
		// var startDate = this.getStartDatePicker().getValue();
		// var selectedStartDate = Ext.Date.format(startDate, 'M j, Y');
		// console.log("The start date: "+ selectedStartDate);
		// return; 
		// we want to test to extract date 
		
		var me  = this;
		var record = this.getList().getSelectedObject();
		var list = this.getList();
		me.getViewport().setLoading( true ) ;
		
		if(!record){return;}
		
		Ext.Ajax.request({
		    url: 'api/confirm_sales_order',
		    method: 'POST',
		    params: {
					id : record.get('id')
		    },
		    jsonData: {},
		    success: function(result, request ) {
			// console.log("success in confirming sales order");
			// console.log(result);
					var decodedResult = Ext.decode( result['responseText'] ) ;
					
					// console.log(decodedResult);
					
					me.getViewport().setLoading( false );
					
					if( decodedResult['success'] === false ){
						Ext.MessageBox.show({
						           title: 'DELETE FAIL',
						           msg: decodedResult["message"]['errors']['generic_errors'],
						           buttons: Ext.MessageBox.OK, 
						           icon: Ext.MessageBox.ERROR
						       });
					}else{
						list.getStore().load({
							callback : function(records, options, success){
								// this => refers to a store 
								record = this.getById(record.get('id'));
								// record = records.getById( record.get('id'))
								list.fireEvent('confirmed', record);
							}
						});
					}
					
					
				
						
						
						
		    },
		    failure: function(result, request ) {
						me.getViewport().setLoading( false ) ;
						console.log("failure in confirming sales order");
		    }
		});
	},


 

	loadObjectList : function(me){
		me.getStore().load();
	},

  addObject: function() {
    var view = Ext.widget('salesorderform');
    view.show();
  },

  editObject: function() {
    var record = this.getList().getSelectedObject();
		if(!record){return;}
    var view = Ext.widget('salesorderform');
	
    view.down('form').loadRecord(record);
		view.setComboBoxData(record); 
  },

  updateObject: function(button) {
    var win = button.up('window');
    var form = win.down('form');

    var store = this.getSalesOrdersStore();
		var list = this.getList();
    var record = form.getRecord();
    var values = form.getValues();

		 
		

		
		if( record ){
			record.set( values );
			 
			form.setLoading(true);
			record.save({
				success : function(record){
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					store.load();
					win.close();
					list.fireEvent('updated', record );
				},
				failure : function(record,op ){
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					this.reject();
				}
			});
				
			 
		}else{
			//  no record at all  => gonna create the new one 
			var me  = this; 
			var newObject = new AM.model.SalesOrder( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
					//  since the grid is backed by store, if store changes, it will be updated
					store.load();
					form.setLoading(false);
					win.close();
					list.fireEvent('updated', record);
					
				},
				failure: function( record, op){
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					this.reject();
				}
			});
		} 
  },

  deleteObject: function() {
    var record = this.getList().getSelectedObject();
		if(!record){return;}
		var list  = this.getList();
		list.setLoading(true); 
		
    if (record) {
			record.destroy({
				success : function(record){
					list.setLoading(false);
					list.fireEvent('deleted');	
					// this.getList().query('pagingtoolbar')[0].doRefresh();
					// console.log("Gonna reload the shite");
					// this.getSalesOrdersStore.load();
					list.getStore().load();
				},
				failure : function(record,op ){
					list.setLoading(false);
				}
			});
    }

  },

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();
		var record = this.getList().getSelectedObject();
		
		if(!record){
			return; 
		}
		var salesOrderEntryGrid = this.getSalesOrderEntryList();
		// salesOrderEntryGrid.setTitle("Purchase Order: " + record.get('code'));
		salesOrderEntryGrid.setObjectTitle( record ) ;
		salesOrderEntryGrid.getStore().load({
			params : {
				sales_order_id : record.get('id')
			},
			callback : function(records, options, success){
				
				var totalObject  = records.length;
				if( totalObject ===  0 ){
					salesOrderEntryGrid.enableRecordButtons(); 
				}else{
					salesOrderEntryGrid.enableRecordButtons(); 
				}
			}
		});
		

    if (selections.length > 0) {
      grid.enableRecordButtons();
    } else {
      grid.disableRecordButtons();
    }
  } 
	

});
