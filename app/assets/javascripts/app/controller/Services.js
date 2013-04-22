Ext.define('AM.controller.Services', {
  extend: 'Ext.app.Controller',

  stores: ['Services'],
  models: ['Service'],

  views: [
    'master.service.List',
    'master.service.Form',
		'master.servicecomponent.List'
  ],

  	refs: [
		{
			ref: 'list',
			selector: 'servicelist'
		},
		{
			ref: 'serviceComponentList',
			selector: 'servicecomponentlist'
		},
		{
			ref : 'searchField',
			selector: 'servicelist textfield[name=searchField]'
		},
		{
			ref: 'viewport',
			selector: 'vp'
		}
	],

  init: function() {
    this.control({
      'servicelist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList,
      },
      'serviceform button[action=save]': {
        click: this.updateObject
      },
      'servicelist button[action=addObject]': {
        click: this.addObject
      },
      'servicelist button[action=editObject]': {
        click: this.editObject
      },
      'servicelist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'servicelist textfield[name=searchField]': {
        change: this.liveSearch
      }
		
    });
  },

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getServicesStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getServicesStore().load();
	},
 

	loadObjectList : function(me){
		me.getStore().load();
	},

  addObject: function() {
    var view = Ext.widget('serviceform');
    view.show();
  },

  editObject: function() {
		var me = this; 
    var record = this.getList().getSelectedObject();
    var view = Ext.widget('serviceform');

		

    view.down('form').loadRecord(record);
  },

  updateObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');

    var store = this.getServicesStore();
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
			var newObject = new AM.model.Service( values ) ;
			
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

		// this.getList().fireEvent("deleted");
		// return; 
		
    if (record) {
      var store = this.getServicesStore();
      store.remove(record);
      store.sync();
// to do refresh programmatically
			this.getList().query('pagingtoolbar')[0].doRefresh();
			
			this.getList().fireEvent("deleted");
    }

  },

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();
		var record = this.getList().getSelectedObject();
		
		if(!record){
			return; 
		}
		var serviceComponentGrid = this.getServiceComponentList();
		// serviceComponentGrid.setTitle("Purchase Order: " + record.get('code'));
		serviceComponentGrid.setObjectTitle( record ) ;
		serviceComponentGrid.getStore().load({
			params : {
				service_id : record.get('id')
			},
			callback : function(records, options, success){
				
				var totalObject  = records.length;
				if( totalObject ===  0 ){
					serviceComponentGrid.enableRecordButtons(); 
				}else{
					serviceComponentGrid.enableRecordButtons(); 
				}
			}
		});
		
		// this.getList().fireEvent("selectionchange");
		
    if (selections.length > 0) {
      grid.enableRecordButtons();
    } else {
      grid.disableRecordButtons();
    }
  }

});
