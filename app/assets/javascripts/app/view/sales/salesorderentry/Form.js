Ext.define('AM.view.sales.salesorderentry.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.salesorderentryform',

  title : 'Add / Edit Entry',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	parentRecord : null, 

	constructor : function(cfg){
		this.parentRecord = cfg.parentRecord;
		this.callParent(arguments);
	},
	
  initComponent: function() {

		if( !this.parentRecord){ return; }
	
		var remoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'item_search',
			fields	: [
				{
					name : 'item_id',
					mapping  :'id'
				},
				{
					name : 'item_name',
					mapping : 'name'
				},
				{
					name : 'selling_price',
					mapping : 'selling_price'
				}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_item',
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			}
		});
		
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
					fieldLabel: 'Sales Order',
					name: 'sales_order_code',
					value: '10'
				},
				{
					fieldLabel: 'Item',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'item_name',
					valueField : 'item_id',
					pageSize : 5,
					minChars : 1, 
					triggerAction: 'all',
					store : remoteJsonStore, 
					listConfig : {
						getInnerTpl: function(){
							return  '<div data-qtip="{item_name}">' + 
												'<div class="combo-name">{item_name}</div>' + 
												'<div>Harga Jual: {selling_price}</div>' + 
											'</div>';
						}
					},
					name : 'entry_id'
				},
				{
	        xtype: 'textfield',
	        fieldLabel: ' Quantity',
					name : 'quantity',
	      },
				{
	        xtype: 'textfield',
	        fieldLabel: ' Discount (%)',
					name : 'discount',
	      },
				{
					fieldLabel: 'Penjual',
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
	        xtype: 'hidden',
	        name : 'entry_case',
	        fieldLabel: 'Entry Case',
					value: 1 
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
		this.down('form').getForm().findField('sales_order_code').setValue(record.get('code')); 
	},
	
	
	setSelectedItem: function( item_id ){
		var comboBox = this.down('form').getForm().findField('entry_id'); 
		var me = this; 
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : item_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( item_id );
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
		
		me.setSelectedItem( record.get("entry_id")  ) ;
		me.setSelectedEmployee( record.get("employee_id")  ) ;

	}
});

