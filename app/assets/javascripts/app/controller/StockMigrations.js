Ext.define('AM.controller.StockMigrations', {
  extend: 'Ext.app.Controller',

  stores: ['StockMigrations', 'Items'],
  models: ['StockMigration'],
	
	  views: [
		'inventory.item.List',
		'inventory.stockmigration.List'
	  ],
	
	  refs: [
		{
			ref: 'list',
			selector: 'stockmigrationlist'
		},
		{
			ref : 'parentList',
			selector : 'itemlist'
		},
		{
			ref: 'stockMigrationList',
			selector: 'stockmigrationlist'
		},
	],

	  init: function() {
	    this.control({
	      'stockmigrationlist': {
	        itemdblclick: this.editObject,
	        selectionchange: this.selectionChange ,
				afterrender : this.loadObjectList
	      },
	      'stockmigrationform button[action=save]': {
	        click: this.updateObject
	      },
	      'stockmigrationlist button[action=addObject]': {
	        click: this.addObject
	      },
	      'stockmigrationlist button[action=editObject]': {
	        click: this.editObject
	      },
	      'stockmigrationlist button[action=deleteObject]': {
	        click: this.deleteObject
	      },
	
			// monitor parent(service) update
			'itemlist' : {
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
		var store = this.getStockMigrationsStore();
		
		store.load({
			params : {
				item_id : record.get('id')
			}
		});
		
		list.setObjectTitle(record);
	},
	
	cleanList : function(){
		var list = this.getList();
		var store = this.getStockMigrationsStore();
		
		list.setTitle('');
		// store.removeAll(); 
		store.loadRecords([], {addRecords: false});
		this.getList().disableRecordButtons();
	},
	 
	
	  addObject: function() {
		
		// I want to get the currently selected item 
		var record = this.getParentList().getSelectedObject();
		if(!record){
			return; 
		}
		 
	    var view = Ext.widget('stockmigrationform', {
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
	
	    var view = Ext.widget('stockmigrationform', {
			parentRecord : parentRecord
		});
	
	    view.down('form').loadRecord(record);
		view.setParentData( parentRecord );
		// console.log("selected record id: " + record.get('id'));
		// console.log("The selected poe id: " + record.get('purchase_order_entry_id'));
		// view.setComboBoxData(record); 
	  },
	
	  updateObject: function(button) {
	    var win = button.up('window');
	    var form = win.down('form');
	
		var parentRecord = this.getParentList().getSelectedObject();
	
	    var store = this.getStockMigrationsStore();
	    var record = form.getRecord();
	    var values = form.getValues();
	
		
		if( record ){
			record.set( values );
			 
			form.query('checkbox').forEach(function(checkbox){
				record.set( checkbox['name']  ,checkbox['checked'] ) ;
			});
			
			form.setLoading(true);
			record.save({
				params : {
					item_id : parentRecord.get('id')
				},
				success : function(record){
					form.setLoading(false);
					form.fireEvent('item_quantity_changed');
					//  since the grid is backed by store, if store changes, it will be updated
					// form.fireEvent('item_quantity_changed');
					store.load({
						params: {
							item_id : parentRecord.get('id')
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
		
			var newObject = new AM.model.StockMigration( values ) ;
			
		 
			
			form.query('checkbox').forEach(function(record){
				newObject.set( record['name']  ,record['checked'] ) ;
			});
			
			// populate the checkbox value to the object 
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				params : {
					item_id : parentRecord.get('id')
				},
				extraParams : {
					item_id : parentRecord.get('id')
				},
				success: function(record){
					//  since the grid is backed by store, if store changes, it will be updated
					store.load({
						params: {
							item_id : parentRecord.get('id')
						}
					});
					form.fireEvent('item_quantity_changed');
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
		var parent_id = record.get('item_id');
		var list  = this.getList();
		
		
		
		// list.fireEvent("deleted");
		// return; 
		
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
							item_id : parent_id
						}
					});
					list.fireEvent("deleted");
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
	 
	
	    if (selections.length > 0) {
	      grid.enableRecordButtons();
	    } else {
	      grid.disableRecordButtons();
	    }
	  }

});
