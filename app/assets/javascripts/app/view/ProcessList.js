Ext.define('AM.view.ProcessList', {
    extend: 'Ext.tree.Panel',
    alias: 'widget.processList',

    
    title: 'Process List',
    rootVisible: false,
		cls: 'examples-list',
    lines: false,
    useArrows: true,

		store: 'Navigations'
});
