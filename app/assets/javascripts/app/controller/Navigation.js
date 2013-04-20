Ext.define("AM.controller.Navigation", {
	extend : "Ext.app.Controller",
	views : [
		"ProcessList"
	],

	 
	
	refs: [
		{
			ref: 'processList',
			selector: 'processList'
		} ,
		{
			ref : 'worksheetPanel',
			selector : '#worksheetPanel'
		}
	],
	 
	init : function( application ) {
		var me = this; 
		 
		me.control({
			"processList" : {
				'select' : this.onTreeRecordSelected
			} 
			
		});
		
	},
	
	onTreeRecordSelected : function( me, record, item, index, e ){
		if (!record.isLeaf()) {
        return;
    }

		this.setActiveExample( record.get('viewClass'), record.get('text'));
	},
	setActiveExample: function(className, title) {
			// console.log("Gonna set active example");
			
      var worksheetPanel = this.getWorksheetPanel();
      
      // console.log("Gonna set title");
      worksheetPanel.setTitle(title);
      
      // console.log("gonna create the worksheet with className: "  +className );
      worksheet = Ext.create(className);
        
			// if(worksheet){
			// 	console.log( "worksheet presents");
			// }else{
			// 	console.log(" !!!!!!!!!!!!!!!! worksheet is not created");
			// }

			// console.log("Gonna remove all shite");
      worksheetPanel.removeAll();
			// console.log("gonna add the newly created worksheet");
      worksheetPanel.add(worksheet);
			// console.log("done adding worksheet");
 
  }
});