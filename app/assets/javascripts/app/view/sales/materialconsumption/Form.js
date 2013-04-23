Ext.define('AM.view.sales.materialconsumption.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.materialconsumptionform',

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
		
 		var serviceComponentRemoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'service_component_search',
			fields	: [
				{
					name : 'service_component_id',
					mapping  :'id'
				},
				{
					name : 'service_component_name',
					mapping : 'name'
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
		
		var usageOptionRemoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'usage_option_search',
			fields	: [
				{
					name : 'usage_option_details',
					mapping  :'details'
				},
				{
					name : 'usage_option_id',
					mapping : 'id'
				},
				{
					name : 'usage_option_item_quantity',
					mapping : 'quantity'
				},
				{
					name : 'usage_option_item_name',
					mapping : 'item_name'
				}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_usage_option',
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
					title: "Penggunaan Bahan Baku",
					items : [
						{
							fieldLabel: 'Kegiatan Jasa',
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
						},
						
						{
							fieldLabel: 'Bahan Baku',
							xtype: 'combo',
							queryMode: 'remote',
							forceSelection: true, 
							displayField : 'usage_option_details',
							valueField : 'usage_option_id',
							pageSize : 5,
							minChars : 1, 
							triggerAction: 'all',
							store : usageOptionRemoteJsonStore, 
							listConfig : {
								getInnerTpl: function(){
									return  '<div data-qtip="{usage_option_details}">' + 
														'<div class="combo-name">{usage_option_details}</div>' + 
													'</div>';
								}
							},
							name : 'usage_option_id'
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
	
	setSelectedUsageOption: function( usage_option_id ){
		var comboBox = this.down('form').getForm().findField('usage_option_id'); 
		var me = this; 
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : usage_option_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( usage_option_id );
			}
		});
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
	
	
	setComboBoxData : function( record){

		var me = this; 
		me.setLoading(true);
		
		me.setSelectedUsageOption( record.get("usage_option_id")  ) ;
		me.setSelectedServiceComponent( record.get("service_component_id")  ) ;

	}
});

