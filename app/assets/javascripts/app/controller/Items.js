Ext.define('AM.controller.Items', {
  extend: 'Ext.app.Controller',

  stores: ['Items'],
  models: ['Item'],

  views: [
    'inventory.item.List',
    'inventory.item.Form',
		'inventory.stockmigration.List'
  ],

  	refs: [
		{
			ref: 'list',
			selector: 'itemlist'
		},
		{
			ref : 'searchField',
			selector: 'itemlist textfield[name=searchField]'
		},
		
		{
			ref: 'stockMigrationList',
			selector: 'stockmigrationlist'
		}
	],

  init: function() {
    this.control({
      'itemlist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList,
      },
      'itemform button[action=save]': {
        click: this.updateObject
      },
      'itemlist button[action=addObject]': {
        click: this.addObject
      },
      'itemlist button[action=editObject]': {
        click: this.editObject
      },
      'itemlist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'itemlist textfield[name=searchField]': {
        change: this.liveSearch
      },

			'stockmigrationform form' : {
				'item_quantity_changed' : function(){
					this.getItemsStore().load();
				}
			},
		
    });
  },

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getItemsStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getItemsStore().load();
	},
 

	loadObjectList : function(me){
		me.getStore().load();
	},

  addObject: function() {
    var view = Ext.widget('itemform');
    view.show();
  },

  editObject: function() {
		var me = this; 
    var record = this.getList().getSelectedObject();
    var view = Ext.widget('itemform');

		

    view.down('form').loadRecord(record);
  },

  updateObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');

    var store = this.getItemsStore();
    var record = form.getRecord();
    var values = form.getValues();

		
		if( record ){
			record.set( values );
			 
			form.setLoading(true);
			record.save({
				success : function(record){
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					
					// store.getProxy().extraParams = {
					//     livesearch: ''
					// };
	 
					store.load();
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
			var newObject = new AM.model.Item( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
	
					store.load();
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

    if (record) {
      var store = this.getItemsStore();
      store.remove(record);
      store.sync();
// to do refresh programmatically
			this.getList().query('pagingtoolbar')[0].doRefresh();
    }

  },

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();


		var record = this.getList().getSelectedObject();
		
		if(!record){
			return; 
		}
		var stockMigrationGrid = this.getStockMigrationList();
		// stockMigrationGrid.setTitle("Purchase Order: " + record.get('code'));
		stockMigrationGrid.setObjectTitle( record ) ;
		stockMigrationGrid.getStore().load({
			params : {
				item_id : record.get('id')
			},
			callback : function(records, options, success){
				
				var totalObject  = records.length;
				if( totalObject ===  0 ){
					stockMigrationGrid.enableRecordButtons(); 
				}else{
					stockMigrationGrid.enableRecordButtons(); 
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
