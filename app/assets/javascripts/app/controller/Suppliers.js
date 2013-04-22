Ext.define('AM.controller.Suppliers', {
  extend: 'Ext.app.Controller',

  stores: ['Suppliers'],
  models: ['Supplier'],

  views: [
    'inventory.supplier.List',
    'inventory.supplier.Form'
  ],

  	refs: [
		{
			ref: 'list',
			selector: 'supplierlist'
		},
		{
			ref : 'searchField',
			selector: 'supplierlist textfield[name=searchField]'
		}
	],

  init: function() {
    this.control({
      'supplierlist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList,
      },
      'supplierform button[action=save]': {
        click: this.updateObject
      },
      'supplierlist button[action=addObject]': {
        click: this.addObject
      },
      'supplierlist button[action=editObject]': {
        click: this.editObject
      },
      'supplierlist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'supplierlist textfield[name=searchField]': {
        change: this.liveSearch
      }
		
    });
  },

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getSuppliersStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getSuppliersStore().load();
	},
 

	loadObjectList : function(me){
		me.getStore().load();
	},

  addObject: function() {
    var view = Ext.widget('supplierform');
    view.show();
  },

  editObject: function() {
		var me = this; 
    var record = this.getList().getSelectedObject();
    var view = Ext.widget('supplierform');

		

    view.down('form').loadRecord(record);
  },

  updateObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');

    var store = this.getSuppliersStore();
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
			var newObject = new AM.model.Supplier( values ) ;
			
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
      var store = this.getSuppliersStore();
      store.remove(record);
      store.sync();
// to do refresh programmatically
			this.getList().query('pagingtoolbar')[0].doRefresh();
    }

  },

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();

    if (selections.length > 0) {
      grid.enableRecordButtons();
    } else {
      grid.disableRecordButtons();
    }
  }

});
