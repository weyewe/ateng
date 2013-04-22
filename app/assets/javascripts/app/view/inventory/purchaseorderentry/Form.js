Ext.define('AM.view.inventory.purchaseorderentry.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.purchaseorderentryform',

  title : 'Add / Edit Entry',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
		var remoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'item_search',
			fields	: ['id','name', 'customer_code', 'supplier_code'],
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
					fieldLabel: 'Purchase Order',
					name: 'purchase_order_code',
					value: '10'
				},
				{
					fieldLabel: 'Item',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'name',
					valueField : 'id',
					pageSize : 5,
					minChars : 1, 
					triggerAction: 'all',
					store : remoteJsonStore, 
					listConfig : {
						getInnerTpl: function(){
							return '<div data-qtip="{name}">' + 
							'<div class="combo-name">{name}</div>' + 
							'<div class="combo-full-address">{customer_code}</div>' + 
							'<div class="combo-full-address">{supplier_code}</div>' + 
							'</div>';
						}
					},
					name : 'item_id'
				},
				{
	        xtype: 'textfield',
	        fieldLabel: ' Quantity',
					name : 'quantity',
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
		this.down('form').getForm().findField('purchase_order_code').setValue(record.get('code')); 
	},
	
	setComboBoxData : function( record){
		var me = this; 
		me.setLoading(true);
		var comboBox = this.down('form').getForm().findField('item_id'); 
		
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : record.get("item_id")
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( record.get("item_id"));
			}
		});
	}
});

