Ext.define('AM.controller.PurchaseOrders', {
  extend: 'Ext.app.Controller',

  stores: ['PurchaseOrders'],
  models: ['PurchaseOrder'],

  views: [
    'inventory.purchaseorder.List',
    'inventory.purchaseorder.Form',
		'inventory.purchaseorderentry.List'
  ],

  refs: [
		{
			ref: 'list',
			selector: 'purchaseorderlist'
		},
		{
			ref : 'purchaseOrderEntryList',
			selector : 'purchaseorderentrylist'
		},
		{
			ref: 'viewport',
			selector: 'vp'
		}
	],

  init: function() {
    this.control({
      'purchaseorderlist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList,
      },
      'purchaseorderform button[action=save]': {
        click: this.updateObject
      },
      'purchaseorderlist button[action=addObject]': {
        click: this.addObject
      },
      'purchaseorderlist button[action=editObject]': {
        click: this.editObject
      },
      'purchaseorderlist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'purchaseorderlist button[action=confirmObject]': {
        click: this.confirmObject
      },


    });
  },

	confirmObject: function(){
		var me  = this;
		var record = this.getList().getSelectedObject();
		var list = this.getList();
		
		
		if(!record){return;}
		me.getViewport().setLoading( true ) ;
		
		Ext.Ajax.request({
		    url: 'api/confirm_purchase_order',
		    method: 'POST',
		    params: {
					id : record.get('id')
		    },
		    jsonData: {},
		    success: function(result, request ) {
						me.getViewport().setLoading( false );
						list.getStore().load({
							callback : function(records, options, success){
								// this => refers to a store 
								record = this.getById(record.get('id'));
								// record = records.getById( record.get('id'))
								list.fireEvent('confirmed', record);
							}
						});
						
		    },
		    failure: function(result, request ) {
						me.getViewport().setLoading( false ) ;
		    }
		});
	},


 

	loadObjectList : function(me){
		me.getStore().load();
	},

  addObject: function() {
    var view = Ext.widget('purchaseorderform');
    view.show();
  },

  editObject: function() {
    var record = this.getList().getSelectedObject();
		if(!record){return;}
    var view = Ext.widget('purchaseorderform');
	
    view.down('form').loadRecord(record);
		view.setComboBoxData(record); 
  },

  updateObject: function(button) {
    var win = button.up('window');
    var form = win.down('form');

    var store = this.getPurchaseOrdersStore();
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
					this.reject()
				}
			});
				
			 
		}else{
			//  no record at all  => gonna create the new one 
			var me  = this; 
			var newObject = new AM.model.PurchaseOrder( values ) ;
			
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
					this.reject()
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
					// this.getPurchaseOrdersStore.load();
					list.getStore().load();
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

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();
		var record = this.getList().getSelectedObject();
		
		if(!record){
			return; 
		}
		var purchaseOrderEntryGrid = this.getPurchaseOrderEntryList();
		// purchaseOrderEntryGrid.setTitle("Purchase Order: " + record.get('code'));
		purchaseOrderEntryGrid.setObjectTitle( record ) ;
		purchaseOrderEntryGrid.getStore().load({
			params : {
				purchase_order_id : record.get('id')
			},
			callback : function(records, options, success){
				
				var totalObject  = records.length;
				if( totalObject ===  0 ){
					purchaseOrderEntryGrid.enableRecordButtons(); 
				}else{
					purchaseOrderEntryGrid.enableRecordButtons(); 
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
