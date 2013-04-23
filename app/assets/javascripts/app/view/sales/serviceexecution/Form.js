Ext.define('AM.view.sales.serviceexecution.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.serviceexecutionform',

  title : 'Add / Edit Entry',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	parentRecord : null, 
	// autoHeight : true, 
	
	
	// overflow : auto, 

	constructor : function(cfg){
		this.parentRecord = cfg.parentRecord;
		this.callParent(arguments);
	},
	
  initComponent: function() {

		if( !this.parentRecord){ return; }
		var me = this; 
		
 		var employeeRemoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'employee_search',
			fields	: [
				{
					name : 'employee_id',
					mapping  :'id'
				},
				{
					name : 'employee_name',
					mapping : 'name'
				}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_employee',
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			}
		});
		
		var serviceComponentRemoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'service_component_search',
			fields	: [
				{
					name : 'service_component_name',
					mapping  :'name'
				},
				{
					name : 'service_component_id',
					mapping : 'id'
				}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_service_component',
				extraParams: {
					service_id : this.parentRecord.get('entry_id')
		    },
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			}
		});
		
		
	 
		this.items = [{
      xtype: 'form',
			msgTarget	: 'side',
			border: false,
      bodyPadding: 10,
			fieldDefaults: {
          labelWidth: 165,
					anchor: '100%'
      },
      items: [
				{
					xtype: 'displayfield',
					fieldLabel: 'Pengerjaan Jasa',
					name: 'sellable_name',
					value: '10'
				},
				{
					xtype: 'fieldset',
					title: "Pelaksana",
					items : [
						{
							fieldLabel: 'Karyawan',
							xtype: 'combo',
							queryMode: 'remote',
							forceSelection: true, 
							displayField : 'employee_name',
							valueField : 'employee_id',
							pageSize : 5,
							minChars : 1, 
							triggerAction: 'all',
							store : employeeRemoteJsonStore, 
							listConfig : {
								getInnerTpl: function(){
									return  '<div data-qtip="{employee_name}">' + 
														'<div class="combo-name">{employee_name}</div>' + 
													'</div>';
								}
							},
							name : 'employee_id'
						},
						
						{
							fieldLabel: 'Jasa',
							xtype: 'combo',
							queryMode: 'remote',
							forceSelection: true, 
							displayField : 'service_component_name',
							valueField : 'service_component_id',
							pageSize : 5,
							minChars : 1, 
							triggerAction: 'all',
							store : serviceComponentRemoteJsonStore, 
							listConfig : {
								getInnerTpl: function(){
									return  '<div data-qtip="{service_component_name}">' + 
														'<div class="combo-name">{service_component_name}</div>' + 
													'</div>';
								}
							},
							name : 'service_component_id'
						}
						
					]
				}
			]
    }];


		
		
    this.buttons = [{
      text: 'Save',
      action: 'save'
    }, {
      text: 'Cancel',
      scope: this,
      handler: this.close
    }];

    this.callParent(arguments);
  },

	


	setParentData: function( record ){
		this.down('form').getForm().findField('sellable_name').setValue(record.get('sellable_name')); 
	},
	
	
	setSelectedServiceComponent: function( service_component_id ){
		var comboBox = this.down('form').getForm().findField('service_component_id'); 
		var me = this; 
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : service_component_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( service_component_id );
			}
		});
	},
	
	setSelectedEmployee: function( employee_id ){
		var comboBox = this.down('form').getForm().findField('employee_id'); 
		var me = this; 
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : employee_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( employee_id );
			}
		});
	},
	setComboBoxData : function( record){

		var me = this; 
		me.setLoading(true);
		
		me.setSelectedServiceComponent( record.get("service_component_id")  ) ;
		me.setSelectedEmployee( record.get("employee_id")  ) ;

	}
});

