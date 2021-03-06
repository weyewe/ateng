Ext.define('AM.controller.SalesOrderEntries', {
  extend: 'Ext.app.Controller',

  stores: ['SalesOrderEntries', 'SalesOrders'],
  models: ['SalesOrderEntry'],

  views: [
    'sales.salesorderentry.List',
    'sales.salesorderentry.Form',
		'sales.salesorderentry.ServiceForm',
		'sales.salesorder.List',
		'sales.serviceexecution.List'
  ],

  refs: [
		{
			ref: 'list',
			selector: 'salesorderentrylist'
		},
		{
			ref : 'parentList',
			selector : 'salesorderlist'
		},
		{
			ref: 'serviceExecutionList',
			selector: 'serviceexecutionlist'
		},
		
		{
			ref: 'materialConsumptionList',
			selector: 'materialconsumptionlist'
		},
	],

  init: function() {
    this.control({
      'salesorderentrylist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange ,
				afterrender : this.loadObjectList
      },
      'salesorderentryform button[action=save], salesorderentryserviceform button[action=save]  ': {
        click: this.updateObject
      },
      'salesorderentrylist button[action=addObject]': {
        click: this.addObject
      },

			'salesorderentrylist button[action=addServiceObject]': {
        click: this.addServiceObject
      },
      'salesorderentrylist button[action=editObject]': {
        click: this.editObject
      },
      'salesorderentrylist button[action=deleteObject]': {
        click: this.deleteObject
      },

			// monitor parent(sales_order) update
			'salesorderlist' : {
				'updated' : this.reloadStore,
				'confirmed' : this.reloadStore,
				'deleted' : this.cleanList
			}
		
    });
  },

	loadObjectList : function(me){
		me.getStore().loadData([],false);
	},

	reloadStore : function(record){
		var list = this.getList();
		var store = this.getSalesOrderEntriesStore();
		
		store.load({
			params : {
				sales_order_id : record.get('id')
			}
		});
		
		list.setObjectTitle(record);
	},
	
	cleanList : function(){
		var list = this.getList();
		var store = this.getSalesOrderEntriesStore();
		
		list.setTitle('');
		// store.removeAll(); 
		store.loadRecords([], {addRecords: false});
	},
 

  addObject: function() {
		
		// I want to get the currently selected item 
		var record = this.getParentList().getSelectedObject();
		if(!record){
			return; 
		}
		 
    var view = Ext.widget('salesorderentryform', {
			parentRecord : record 
		});
		view.setParentData( record );
    view.show(); 
  },

	addServiceObject: function() {
		
		// I want to get the currently selected item 
		var record = this.getParentList().getSelectedObject();
		if(!record){
			return; 
		}
		 
    var view = Ext.widget('salesorderentryserviceform', {
			parentRecord : record 
		});
		view.setParentData( record );
    view.show(); 
  },

  editObject: function() {
		var parentRecord = this.getParentList().getSelectedObject();
		
    var record = this.getList().getSelectedObject();
		if(!record || !parentRecord){
			return; 
		}
		
		
		var widgetName = 'salesorderentryform'
		if(record.get("entry_case") === 2 ){
			widgetName = 'salesorderentryserviceform'; 
		}

    var view = Ext.widget( widgetName , {
			parentRecord : parentRecord
		});

    view.down('form').loadRecord(record);
		view.setParentData( parentRecord );
		// console.log("selected record id: " + record.get('id'));
		// console.log("The selected poe id: " + record.get('purchase_order_entry_id'));
		view.setComboBoxData(record); 
  },

  updateObject: function(button) {
    var win = button.up('window');
    var form = win.down('form');

		var parentRecord = this.getParentList().getSelectedObject();
    var store = this.getSalesOrderEntriesStore();
    var record = form.getRecord();
    var values = form.getValues();

		
		if( record ){
			record.set( values );
			 
			form.setLoading(true);
			record.save({
				params : {
					sales_order_id : parentRecord.get('id')
				},
				success : function(record){
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					// form.fireEvent('item_quantity_changed');
					store.load({
						params: {
							sales_order_id : parentRecord.get('id')
						}
					});
					
					win.close();
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
			var newObject = new AM.model.SalesOrderEntry( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				params : {
					sales_order_id : parentRecord.get('id')
				},
				success: function(record){
					//  since the grid is backed by store, if store changes, it will be updated
					store.load({
						params: {
							sales_order_id : parentRecord.get('id')
						}
					});
					// form.fireEvent('item_quantity_changed');
					form.setLoading(false);
					win.close();
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
		var parent_id = record.get('sales_order_id');
		var list  = this.getList();
		list.setLoading(true); 
		
    if (record) {
			record.destroy({
				success : function(record){
					list.setLoading(false);
					list.fireEvent('deleted');	
					// this.getList().query('pagingtoolbar')[0].doRefresh();
					// console.log("Gonna reload the shite");
					// this.getPurchaseOrdersStore.load();
					list.getStore().load({
						params : {
							sales_order_id : parent_id
						}
					});
				},
				failure : function(record,op ){
					list.setLoading(false);
					
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					
					if( errors["generic_errors"] ){
						Ext.MessageBox.show({
						           title: 'DELETE FAIL',
						           msg: errors["generic_errors"],
						           buttons: Ext.MessageBox.OK, 
						           icon: Ext.MessageBox.ERROR
						       });
					}
					
				}
			});
    }

  },

	enableServiceExecutionGrid: function( record ){
		var serviceExecutionGrid = this.getServiceExecutionList();
		// serviceComponentGrid.setTitle("Purchase Order: " + record.get('code'));
		serviceExecutionGrid.setObjectTitle( record ) ;
		serviceExecutionGrid.getStore().load({
			params : {
				sales_order_entry_id : record.get('id')
			},
			callback : function(records, options, success){
				
				var totalObject  = records.length;
				if( totalObject ===  0 ){
					serviceExecutionGrid.enableRecordButtons(  ); 
				}else{
					serviceExecutionGrid.enableRecordButtons(); 
				}
			}
		});
	},
	
	enableMaterialConsumptionGrid: function( record ){
		var materialConsumptionGrid = this.getMaterialConsumptionList();
		// serviceComponentGrid.setTitle("Purchase Order: " + record.get('code'));
		materialConsumptionGrid.setObjectTitle( record ) ;
		materialConsumptionGrid.getStore().load({
			params : {
				sales_order_entry_id : record.get('id')
			},
			callback : function(records, options, success){
				
				var totalObject  = records.length;
				if( totalObject ===  0 ){
					materialConsumptionGrid.enableRecordButtons(  ); 
				}else{
					materialConsumptionGrid.enableRecordButtons(); 
				}
			}
		});
	},
	
	disableServiceExecutionGrid: function(){
		var list  = this.getServiceExecutionList();
		list.setTitle('');
		list.getStore().loadRecords([], {addRecords: false});
		this.getList().disableRecordButtons();
	},
	
	disableMaterialConsumptionGrid: function(){
		var list  = this.getMaterialConsumptionList();
		list.setTitle('');
		list.getStore().loadRecords([], {addRecords: false});
		this.getList().disableRecordButtons();
	},

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();

		var record = this.getList().getSelectedObject();
		if(!record){
			return; 
		}
		
		// form.fireEvent('salesorderentry_selection_change', record);
		
		if( record.get("entry_case") ===  2) { // 2 means service sales_order_entry
			this.enableServiceExecutionGrid( record );
		} else{
			grid.fireEvent('selectionchangetoitem');
		}
		
		

    if (selections.length > 0) {
      grid.enableRecordButtons();
    } else {
      grid.disableRecordButtons();
    }
  }

});
