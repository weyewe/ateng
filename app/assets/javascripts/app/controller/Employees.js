Ext.define('AM.controller.Employees', {
  extend: 'Ext.app.Controller',

  stores: ['Employees'],
  models: ['Employee'],

  views: [
    'management.employee.List',
    'management.employee.Form'
  ],

  	refs: [
		{
			ref: 'list',
			selector: 'employeelist'
		},
		{
			ref : 'searchField',
			selector: 'employeelist textfield[name=searchField]'
		}
	],

  init: function() {
    this.control({
      'employeelist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList,
      },
      'employeeform button[action=save]': {
        click: this.updateObject
      },
      'employeelist button[action=addObject]': {
        click: this.addObject
      },
      'employeelist button[action=editObject]': {
        click: this.editObject
      },
      'employeelist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'employeelist textfield[name=searchField]': {
        change: this.liveSearch
      }
		
    });
  },

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getEmployeesStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getEmployeesStore().load();
	},
 

	loadObjectList : function(me){
		me.getStore().load();
	},

  addObject: function() {
    var view = Ext.widget('employeeform');
    view.show();
  },

  editObject: function() {
		var me = this; 
    var record = this.getList().getSelectedObject();
    var view = Ext.widget('employeeform');

		

    view.down('form').loadRecord(record);
  },

  updateObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getEmployeesStore();
    var record = form.getRecord();
    var values = form.getValues();

		
		if( record ){
			var recordId=  record.get("id");
			record.set( values );
			 
			form.setLoading(true);
			record.save({
				success : function(record){
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					
					// store.getProxy().extraParams = {
					//     livesearch: ''
					// };
	 
					// store.load();
					
					// recommendation from this guy: http://vadimpopa.com/reload-a-single-record-and-refresh-its-extjs-grid-row/
					// reload a single grid 
					// me.getEmployeeModel().load(  recordId , {
					//     scope: list,
					//     failure: function(record, operation) {
					//         //do something if the load failed
					//     },
					//     success: function(record, operation) {
					//         var store = list.getStore(),
					//             recToUpdate = store.getById( recordId );
					// 
					//          recToUpdate.set(record.getData());
					// 
					//      // Do commit if you need: if the data from
					//      // the server differs from last commit data
					//          recordToUpdate.commit();
					// 
					//          list.getView().refreshNode(store.indexOfId( recordId ));
					//     },
					//     callback: function(record, operation) {
					//         //do something whether the load succeeded or failed
					//     }
					// });
					
					
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
			var newObject = new AM.model.Employee( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
	
					// store.load();
					store.add( record );
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
      var store = this.getEmployeesStore();
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
