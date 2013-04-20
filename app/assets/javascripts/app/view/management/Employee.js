Ext.define('AM.view.management.Employee', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.employeeProcess',
	 
		
		items : [
			{
				xtype : 'employeelist' ,
				flex : 1 
			} 
		]
});