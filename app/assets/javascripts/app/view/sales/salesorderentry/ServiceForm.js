Ext.define('AM.view.sales.salesorderentry.ServiceForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.salesorderentryserviceform',

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
			storeId : 'service_search',
			fields	: [
				{
					name : 'service_id',
					mapping  :'id'
				},
				{
					name : 'service_name',
					mapping : 'name'
				},
				{
					name : 'selling_price',
					mapping : 'selling_price'
				}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_service',
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
					fieldLabel: 'Service',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'service_name',
					valueField : 'service_id',
					pageSize : 5,
					minChars : 1, 
					triggerAction: 'all',
					store : remoteJsonStore, 
					listConfig : {
						getInnerTpl: function(){
							return  '<div data-qtip="{service_name}">' + 
												'<div class="combo-name">{service_name}</div>' + 
												'<div>Harga Jual: {selling_price}</div>' + 
											'</div>';
						}
					},
					name : 'entry_id'
				},
				{
	        xtype: 'displayfield',
	        fieldLabel: ' Quantity',
					name : 'quantity',
					value : 1 
	      },
				{
	        xtype: 'textfield',
	        fieldLabel: ' Discount (%)',
					name : 'discount',
	      },
				{
	        xtype: 'hidden',
	        name : 'entry_case',
	        fieldLabel: 'Entry Case',
					value: 2
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
	
	
	setSelectedService: function( service_id ){
		var comboBox = this.down('form').getForm().findField('entry_id'); 
		var me = this; 
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : service_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( service_id );
			}
		});
	},
	
	
	setComboBoxData : function( record){

		var me = this; 
		me.setLoading(true);
		
		me.setSelectedService( record.get("entry_id")  ) ;
	}
});

