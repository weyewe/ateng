Ext.define('AM.view.master.servicecomponent.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.servicecomponentform',

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
					fieldLabel: 'Service',
					name: 'service_name',
					value: '10'
				},
				{
					xtype: 'fieldset',
					title: "Service Component Info",
					items : [
						{
							fieldLabel : 'Nama',
							name : 'name',
							xtype : 'field'
						},
						{
							fieldLabel : 'Komisi',
							name : 'commission_amount',
							xtype : 'field'
						},
						
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
		this.down('form').getForm().findField('service_name').setValue(record.get('name')); 
	},
	
	setSelectedSalesItem: function( sales_item_id ){
		var comboBox = this.down('form').getForm().findField('sales_item_id'); 
		var me = this; 
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : sales_item_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( sales_item_id );
			}
		});
	},
	
 
	
	setSelectedItemCondition: function( item_condition ){
		var comboBox = this.down('form').getForm().findField('item_condition'); 
		var me = this; 
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : item_condition 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( item_condition );
			}
		});
	},
	
	setComboBoxData : function( record){
		var me = this; 
		me.setLoading(true);
		
		
		me.setSelectedSalesItem( record.get("sales_item_id")  ) ;
		me.setSelectedItemCondition( record.get("item_condition")  ) ;
	}
});

