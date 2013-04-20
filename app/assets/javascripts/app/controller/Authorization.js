Ext.define("AM.controller.Authorization", {
	extend : "Ext.app.Controller",
	views : [
		"ProtectedContent"
	],

	 
	
	refs: [
		{
			ref: 'protectedContent',
			selector: 'protected'
		},
		{
			ref : 'userMenu',
			selector : 'appHeader #optionsMenu'
		}
	],
	

	 
	init : function( application ) {
		console.log("Authorization Controller init");
		var me = this; 
		 
		me.control({
			"protected" : {
				activate : this.onActiveProtectedContent
			} 
			
		});
		console.log("End of authorization controller init");
	},


	managementFolder : {
		text 			: "Management", 
		viewClass : '',
		iconCls		: 'text-folder', 
    expanded	: true,
		children 	: [
        
      { 
          text:'Employee', 
          viewClass:'AM.view.management.Employee', 
          leaf:true, 
          iconCls:'text',
 					conditions : [
						{
							controller : "employees",
							action  : 'index'
						}
					]
      },
      { 
          text:'User', 
          viewClass:'AM.view.management.User', 
          leaf:true, 
          iconCls:'text',
 					conditions : [
						{
							controller : "users",
							action  : 'index'
						}
					] 
      },
			{ 
          text:'Cash Account', 
          viewClass:'AM.view.management.CashAccount', 
          leaf:true, 
          iconCls:'text' ,
 					conditions : [
						{
							controller : "cash_accounts",
							action  : 'index'
						}
					]
      }
    ]
	},
	
	inventoryFolder : {
		text:'Inventory', 
    viewClass:'Will', 
    iconCls:'text-folder', 
    expanded: true,
		children : [
			{ 
				text:'Material', 
				viewClass:'AM.view.inventory.Material', 
				leaf:true, 
				iconCls:'text',
				conditions : [
					{
						controller : 'materials',
						action : 'index'
					}
				]
	     }
		]
	},
	
	factoryFolder : {
		text:'Pabrik', 
    viewClass:'Will', 
    iconCls:'text-folder', 
    expanded: true,
		children : [
			{ 
          text:'Penerimaan Bahan Bubut', 
          viewClass:'AM.view.factory.ItemReceival', 
          leaf:true, 
          iconCls:'text' ,
					conditions : [
						{
							controller : 'item_receivals',
							action : 'index'
						}
						
					]
      },
      { 
          text:'Pengerjaan Pabrik', 
          viewClass:'AM.view.factory.TemplateSalesItem', 
          leaf:true, 
          iconCls:'text',
					conditions : [
						{
							controller : 'template_sales_items',
							action : 'index'
						}
					]
      }
		]
		
	},
	
	salesFolder : {
		text:'Sales', 
    viewClass:'Will', 
    iconCls:'text-folder', 
    expanded: true,
		children : [
			{ 
				text:'Customer', 
				viewClass:'AM.view.sales.Customer', 
				leaf:true, 
				iconCls:'text' ,
				conditions : [
					{
						controller : 'customers',
						action : 'index'
					}
				]
			},
			{ 
				text:'Penjualan', 
				viewClass:'AM.view.sales.SalesOrder', 
				leaf:true, 
				iconCls:'text' ,
				conditions : [
					{
						controller : 'sales_orders',
						action : 'index'
					}
				]
			},
			{ 
				text:'Pengiriman', 
				viewClass:'AM.view.sales.Delivery', 
				leaf:true, 
				iconCls:'text' ,
				conditions : [
					{
						controller : 'deliveries',
						action : 'index'
					}
				]
			},
			{ 
				text:'Sales Return', 
				viewClass:'AM.view.sales.SalesReturn', 
				leaf:true, 
				iconCls:'text' ,
				conditions : [
					{
						controller : 'sales_returns',
						action : 'index'
					}
				]
			},
			{ 
				text:'Guarantee Return', 
				viewClass:'AM.view.sales.GuaranteeReturn', 
				leaf:true, 
				iconCls:'text' ,
				conditions : [
					{
						controller : 'guarantee_returns',
						action : 'index'
					}
				]
			}
		]
		
	},
	
	paymentFolder : {
		text:'Payment', 
    viewClass:'Will', 
    iconCls:'text-folder', 
    expanded: true,
		children : [
			{ 
				text:'Invoice', 
				viewClass:'AM.view.payment.Invoice', 
				leaf:true, 
				iconCls:'text' ,
				conditions : [
					{
						controller : 'invoices',
						action : 'index'
					}
				]
			},
			{ 
				text:'Pembayaran', 
				viewClass:'AM.view.payment.Payment', 
				leaf:true, 
				iconCls:'text' ,
				conditions : [
					{
						controller : 'payments',
						action : 'index'
					}
				]
			}
		]
	},
	
	onActiveProtectedContent: function( panel, options) {
		console.log("Inside onActiveProtectedContent");
		var me  = this; 
		var currentUser = Ext.decode( localStorage.getItem('currentUser'));
		var email = currentUser['email'];
		// console.log("onActive Protected Content");
		
		// build the navigation tree 
		var processList = panel.down('processList');
		processList.setLoading(true);
	
		var treeStore = processList.getStore();
		treeStore.removeAll(); 
		
		// // console.log("in onActiveProtectedContent");
		// // console.log("paymentFolder: " ) ;
		// // console.log( this.paymentFolder );
		// //  
		// 
		// var data = {
		//     text:"text root",
		//     children: 
		//         [
		//             {
		//                 text:'Management', 
		//                 viewClass:'', 
		//                 iconCls:'text-folder', 
		//                 expanded: true,
		//                 children:
		//                 [
		//                     
		// 	                    { 
		// 	                        text:'Employee', 
		// 	                        viewClass:'AM.view.management.Employee', 
		// 	                        leaf:true, 
		// 	                        iconCls:'text' 
		// 	                    },
		// 	                    { 
		// 	                        text:'User', 
		// 	                        viewClass:'AM.view.management.User', 
		// 	                        leaf:true, 
		// 	                        iconCls:'text' 
		// 	                    },
		// 									{ 
		// 	                        text:'Cash Account', 
		// 	                        viewClass:'AM.view.management.CashAccount', 
		// 	                        leaf:true, 
		// 	                        iconCls:'text' 
		// 	                    }
		//                     
		//                 ]
		//             },
		//  								{
		//  									text:'Inventory', 
		//  	                viewClass:'Will', 
		//  	                iconCls:'text-folder', 
		//  	                expanded: true,
		//  	                children:
		//  	                [
		//  										{ 
		//  		                     text:'Material', 
		//  		                     viewClass:'AM.view.inventory.Material', 
		//  		                     leaf:true, 
		//  		                     iconCls:'text' 
		//  		                 }
		//  	                ]
		//  								},
		// 						{
		// 							text:'Pabrik', 
		// 	                viewClass:'Will', 
		// 	                iconCls:'text-folder', 
		// 	                expanded: true,
		// 	                children:
		// 	                [
		// 	                
		//                     { 
		//                         text:'Penerimaan Bahan Bubut', 
		//                         viewClass:'AM.view.factory.ItemReceival', 
		//                         leaf:true, 
		//                         iconCls:'text' 
		//                     },
		//                     { 
		//                         text:'Pengerjaan Pabrik', 
		//                         viewClass:'AM.view.factory.TemplateSalesItem', 
		//                         leaf:true, 
		//                         iconCls:'text' 
		//                     }
		// 	                ]
		// 						},
		//  								{
		//  									text:'Sales', 
		//  	                viewClass:'Will', 
		//  	                iconCls:'text-folder', 
		//  	                expanded: true,
		//  	                children:
		//  	                [
		//  	                    
		//                      { 
		//                          text:'Customer', 
		//                          viewClass:'AM.view.sales.Customer', 
		//                          leaf:true, 
		//                          iconCls:'text' 
		//                      },
		//                      { 
		//                          text:'Penjualan', 
		//                          viewClass:'AM.view.sales.SalesOrder', 
		//                          leaf:true, 
		//                          iconCls:'text' 
		//                      },
		//  										{ 
		//                          text:'Pengiriman', 
		//                          viewClass:'AM.view.sales.Delivery', 
		//                          leaf:true, 
		//                          iconCls:'text' 
		//                      },
		//  										{ 
		//                          text:'Sales Return', 
		//                          viewClass:'AM.view.sales.SalesReturn', 
		//                          leaf:true, 
		//                          iconCls:'text' 
		//                      },
		// 								{ 
		//                          text:'Guarantee Return', 
		//                          viewClass:'AM.view.sales.GuaranteeReturn', 
		//                          leaf:true, 
		//                          iconCls:'text' 
		//                      }
		// 								
		//  	                    
		//  	                ]
		//  								},
		// 						{
		//  									text:'Payment', 
		//  	                viewClass:'Will', 
		//  	                iconCls:'text-folder', 
		//  	                expanded: true,
		//  	                children:
		//  	                [
		//  	                    
		//                      { 
		//                          text:'Invoice', 
		//                          viewClass:'AM.view.payment.Invoice', 
		//                          leaf:true, 
		//                          iconCls:'text' 
		//                      },
		//                      { 
		//                          text:'Pembayaran', 
		//                          viewClass:'AM.view.payment.Payment', 
		//                          leaf:true, 
		//                          iconCls:'text' 
		//                      }
		//  	                    
		//  	                ]
		//  								}
		//         ]
		// 	
		//     };
		// 
		// 
		// treeStore.setRootNode(data);
		// processList.setLoading(false);
		
		console.log("Gonna build navigation");
		treeStore.setRootNode( this.buildNavigation(currentUser) );
		processList.setLoading(false);
		
		// Update the title of the menu button
		// console.log("Gonna update the user menu");
		var userMenu = me.getUserMenu();

		userMenu.setText( email );
	},
	
	buildNavigation: function( currentUser ) {
		var me = this; 
		var folderList = [
			this.managementFolder,
			this.inventoryFolder,
			this.factoryFolder, 
			this.salesFolder, 
			this.paymentFolder 
		];
		
		console.log("The length of folderList: " + folderList.length );
		var composedFolders = []; 
		for(var i = 0 ; i < folderList.length ; i++){
			var folder = folderList[i];
			
			console.log("Gonna build the folder");
			var composedFolder = me.buildFolder( currentUser, folder ); 
			if( composedFolder !== null ){
				composedFolders.push( composedFolder );
			}
		}
		
		var data = {
			text : 'text root',
			children : composedFolders
		}
		
		return data; 
	},
	
	buildFolder : function( currentUser, folder ){
		var me = this; 
		console.log("Inside the build folder");
		var processList = [];
		console.log("The length of folder['children']: " + folder['children'].length );
		for( var i =0 ; i < folder['children'].length; i++ ){
			var processTemplate = folder['children'][i];
			var process = me.buildProcess( currentUser, processTemplate );
			if( process !== null){
				processList.push( process );
			}
		}
		
		console.log("*************Done building folder \n\n");
		
		if( processList.length !== 0 ){
			return {
				text: 			folder['text'], 
				viewClass: 	folder['viewClass'], 
				iconCls: 		folder['iconCls'], 
				expanded: 	folder['expanded'],
				children: 	processList 
			};
		}else{
			return null; 
		}
	},
	
	buildProcess : function(currentUser, processTemplate){
		
		if( !currentUser || !currentUser['role']){
			return null; 
		}
		
		var process = {
			text 			: processTemplate['text'],
			viewClass : processTemplate['viewClass'],
			leaf 			: processTemplate['leaf'],
			iconCls 	: processTemplate['iconCls']
		}
		console.log("Inside buildProcess");
		console.log( process );
		
		for( var i =0 ; i < processTemplate['conditions'].length; i++ ){
			var condition = processTemplate['conditions'][i];
			var controller = condition['controller'];
			var action = condition['action'];
			
			if( 
					(
						currentUser['role']['system'] &&
						currentUser['role']['system']['administrator']  
					) || 
					(
							currentUser['role'][controller] && 
							currentUser['role'][controller][action]  
					) ){
				
				console.log("returning the process");
				return process; 
			}
		}
	 
		console.log("returning null in the buildProcess");
		return null; 
	}
	
});