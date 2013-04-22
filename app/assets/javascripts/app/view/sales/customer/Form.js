Ext.define('AM.view.sales.customer.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.customerform',

  title : 'Add / Edit Customer',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
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
	        xtype: 'hidden',
	        name : 'id',
	        fieldLabel: 'id'
	      },{
	        xtype: 'textfield',
	        name : 'name',
	        fieldLabel: ' Name'
	      }// ,{
	      // 					xtype: 'textfield',
	      // 					name : 'phone',
	      // 					fieldLabel: 'Phone'
	      // 				},{
	      // 					xtype: 'textfield',
	      // 					name : 'mobile',
	      // 					fieldLabel: 'HP'
	      // 				},{
	      // 					xtype: 'textfield',
	      // 					name : 'email',
	      // 					fieldLabel: 'Email'
	      // 				},{
	      // 					xtype: 'textfield',
	      // 					name : 'bbm_pin',
	      // 					fieldLabel: 'PIN BB'
	      // 				},{
	      // 					xtype: 'textarea',
	      // 					name : 'address',
	      // 					fieldLabel: 'Alamat'
	      // 				}
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
  }
});
