Ext.define('AM.view.inventory.stockmigration.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.stockmigrationform',

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
		
 
		// var remoteJsonStore = Ext.create(Ext.data.JsonStore, {
		// 	storeId : 'item_search',
		// 	fields	: [
		// 	 				{
		// 				name : 'item_id',
		// 				mapping : "id"
		// 			},
		// 			{
		// 				name : 'item_name',
		// 				mapping : 'name'
		// 			}
		// 	],
		// 	proxy  	: {
		// 		type : 'ajax',
		// 		url : 'api/search_item',
		// 		reader : {
		// 			type : 'json',
		// 			root : 'records', 
		// 			totalProperty  : 'total'
		// 		}
		// 	},
		// 	autoLoad : false 
		// });
		
		// {
		// 	fieldLabel: 'Item',
		// 	xtype: 'combo',
		// 	queryMode: 'remote',
		// 	forceSelection: true, 
		// 	displayField : 'item_name',
		// 	valueField : 'item_id',
		// 	pageSize : 5,
		// 	minChars : 1, 
		// 	allowBlank : false, 
		// 	triggerAction: 'all',
		// 	store : remoteJsonStore, 
		// 	listConfig : {
		// 		getInnerTpl: function(){
		// 			return '<div data-qtip="{item_name}">' +  
		// 								'<div class="combo-name">{item_name}</div>' + 
		// 						 '</div>';
		// 		}
		// 	},
		// 	name : 'item_id' 
		// },
	 
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
					fieldLabel: 'Item',
					name: 'item_name',
					value: '10'
				},
				{
					xtype: 'fieldset',
					title: "Info Stok Awal",
					items : [
						{
							fieldLabel : 'Jumlah Awal',
							name : 'quantity',
							xtype : 'field'
						},
						{
							fieldLabel : 'Harga Average',
							name : 'average_cost',
							xtype : 'field'
						},
						{
			        xtype: 'hidden',
			        name : 'item_id',
			        fieldLabel: 'Item ID'
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
		this.down('form').getForm().findField('item_name').setValue(record.get('name')); 
		this.down('form').getForm().findField('item_id').setValue(record.get('id'));
	}
});

