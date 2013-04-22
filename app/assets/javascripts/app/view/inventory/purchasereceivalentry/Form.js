Ext.define('AM.view.inventory.purchasereceivalentry.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.purchasereceivalentryform',

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
	// get the parent id 
		// console.log("Inside the initComponent of the Form");
		// console.log( this.parentRecord  );
		if( !this.parentRecord){ return; }
	
		var remoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'purchase_order_entry_search',
			fields	: ['id','item_name', 'purchase_order_entry_code', 'purchase_order_code' ],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_purchase_order_entry',
				extraParams: {
					supplier_id : this.parentRecord.get('supplier_id')
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
					fieldLabel: 'Purchase Receival',
					name: 'purchase_receival_code',
					value: '10'
				},
				{
					fieldLabel: 'Item',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'item_name',
					valueField : 'id',
					pageSize : 5,
					minChars : 1, 
					triggerAction: 'all',
					store : remoteJsonStore, 
					listConfig : {
						getInnerTpl: function(){
							return '<div data-qtip="{item_name}">' + 
								'<div class="combo-name">{item_name}</div>' + 
								'<div class="combo-full-address">{purchase_order_entry_code}</div>' + 
								'<div class="combo-full-address">{purchase_order_code}</div>' + 
							'</div>';
						}
					},
					name : 'purchase_order_entry_id'
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
		this.down('form').getForm().findField('purchase_receival_code').setValue(record.get('code')); 
	},
	
	setComboBoxData : function( record){
		// console.log("In the PurchaseReceivalEntry Form");
		// console.log( record ) ;
		var me = this; 
		me.setLoading(true);
		var comboBox = this.down('form').getForm().findField('purchase_order_entry_id'); 
		
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : record.get("purchase_order_entry_id")
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( record.get("purchase_order_entry_id"));
			}
		});
	}
});

