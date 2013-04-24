<script type="text/javascript">
var jslang = "EN";
var jsextv = "3.3.1";
var LBRSTR__WINDOW_TITLE="Ext DatePickerPlus Demo...";var LBRSTR__LOADING="Loading DatePickerPlus Demo...";var LBRSTR__LANGUAGE_SELECTION="Language selection";var LBRSTR__GERMAN="German";var LBRSTR__ENGLISH="English";var LBRSTR__RUSSIAN="Russian";var LBRSTR__ITALIAN="Italian";var LBRSTR__DUTCH="Dutch";var LBRSTR__FRENCH="French";var LBRSTR__NORWEGIAN="Norwegian";var LBRSTR__SPANISH="Spanish";var LBRSTR__ROMANIAN="Romanian";var LBRSTR__JAPANESE="Japanese";var LBRSTR__POLISH="Polish";var LBRSTR__WEEKENDTEXT="This day is part of a Weekend";var LBRSTR__BUY_A_COMMERCIAL_LICENSE="Buy a commercial lifetime license of DatePickerPlus for only 15 EUR";var LBRSTR__VIEW_COMMERCIAL_LICENSE="View commercial license";var LBRSTR__COMMERCIAL_BUTTON_ID="1517902";var LBRSTR_NO_JAVASCRIPT="This page contains the javascript library DatePickerPlus<br>Of course, you need to activate javascript to enjoy the demopage...";Ext.BLANK_IMAGE_URL = '../ext-3.3.1/resources/images/default/s.gif'; 
Ext.onReady(function() {
	var extMajorVersion =parseInt(Ext.version.substr(0,1),10);
/*
//Turn off autoHide for all Quicktips
	Ext.apply(Ext.ToolTip.prototype, {
	    dismissDelay: 0
	});
*/	
	Ext.QuickTips.init();

	function reload_wholepage(moreParameters){
		window.location='./?'+moreParameters;
	}


	var datepickerplusmenu_1 =  new Ext.menu.DateMenu({
		usePickerPlus	: true,
		noOfMonth : 1 ,
		multiSelection: true,
		markNationalHolidays: false,
		useQuickTips:false,
		minDate: new Date(2011, 3, 1),
		maxDate: new Date(2011, 4, 31),
		renderTodayButton:false,
		showToday:false,	//Ext 2.2 own option		
		handler : function(dp, date){
			var allStringDates=[];
//take care of multiselection on/off (on will return an array of dateobjects, false will return one single dateobject)
			if (Ext.isDate(date)) {
				allStringDates.push(date.format('M j, Y'));
			}
			else {
				Ext.each(date,function(c){
					allStringDates.push(c.format('M j, Y'));
				},this);
			}
			Ext.MessageBox.alert('Date(s) Selected', 'You have chosen the following day(s):<br>'+allStringDates.join('<br>'));
		}
				
	});
	
	var datepickerplusmenu_2 =  new Ext.menu.DateMenu({
		usePickerPlus	: true,
		noOfMonth : 3 ,
		noOfMonthPerRow : 3,
		markWeekends: false,
		pageKeyWarp: 3,
		allowedDates: [
			new Date(2011,4,11),
			new Date(2011,4,18),
			new Date(2011,4,14),
			new Date(2011,4,15)									
		],
		handler : function(dp, date){
			var allStringDates=[];
//take care of multiselection on/off (on will return an array of dateobjects, false will return one single dateobject)
			if (Ext.isDate(date)) {
				allStringDates.push(date.format('M j, Y'));
			}
			else {
				Ext.each(date,function(c){
					allStringDates.push(c.format('M j, Y'));
				},this);
			}
			Ext.MessageBox.alert('Date(s) Selected', 'You have chosen the following day(s):<br>'+allStringDates.join('<br>'));
		}
				
	});
	
	var datepickerplusmenu_3 =  new Ext.menu.DateMenu({
		usePickerPlus	: true,
		noOfMonth : 4 ,
		noOfMonthPerRow : 2,
		multiSelection: true,
		multiSelectByCTRL:false,
		maxSelectionDays: 10,
		markNationalHolidays: false,
		weekendText: LBRSTR__WEEKENDTEXT,
		renderOkUndoButtons:false,
		disablePartialUnselect:false,
		eventDates : function(year) {
			var dates = [
			{
				date: new Date(year,4,14),
				text: "My cat died "+(year-2001)+" years ago",
				cls: "x-datepickerplus-eventdates",
				id: "catdied"
			},
			{
				date: new Date(year,4,11), //will be marked every year on 05/11
				text: "May 11th, Author's Birthday (Age:"+(year-1973)+")",
				cls: "x-datepickerplus-eventdates"									
			}
					
			];
			return dates;
		},		
		handler : function(dp, date){
			var allStringDates=[];
			if (Ext.isDate(date)) {
				allStringDates.push(date.format('M j, Y'));
			}
			else {
				Ext.each(date,function(c){
					allStringDates.push(c.format('M j, Y'));
				},this);
			}
			Ext.MessageBox.alert('Date(s) Selected', 'You have chosen the following day(s):<br>'+allStringDates.join('<br>'));
		}
				
	});
	
	var datepickerplusmenu_4 =  new Ext.menu.DateMenu({
		usePickerPlus	: true,
		noOfMonth : 3 ,
		multiSelection: true,
		minDate: new Date(2011, 3, 1),
		maxDate: new Date(2011, 6, 31),
		strictRangeSelect:true,
		handler : function(dp, date){
			var allStringDates=[];
			if (Ext.isDate(date)) {
				allStringDates.push(date.format('M j, Y'));
			}
			else {
				Ext.each(date,function(c){
					allStringDates.push(c.format('M j, Y'));
				},this);
			}
			Ext.MessageBox.alert('Date(s) Selected', 'You have chosen the following day(s):<br>'+allStringDates.join('<br>'));
		}
				
	});

	var dform = Ext.DatePicker.prototype.format;
	var datepickerplus_features = new Ext.Toolbar([
		{
			text	: 'DateMenu 1',
			tooltip	: {
				title:'DateMenu Example 1',
				text:'Single Month, Multiselection, Weekends, Weeknumbers, No Holidays, Browserbased Tooltips, Selectable Days between April and May 2008, No Today-Button<hr>noOfMonth : 1,<br>multiSelection: true,<br>markNationalHolidays: false,<br>useQuickTips:false,<br>minDate: new Date(2008, 3, 1),<br>maxDate: new Date(2008, 4, 31)<br>renderTodayButton:false(needs showToday:false as of Ext 2.2)'
			},
			menu	: datepickerplusmenu_1
		},
		'-',
		{
			text	: 'DateMenu 2',
			tooltip	: {
				title:'DateMenu Example 2',
				text:'Multimonth (3x1), No Multiselection, No Weekends, Weeknumbers, Holidays, Quicktips, 3 Month PageWarp, only a few Days in May 2008 are selectable<hr>noOfMonth : 3,<br>noOfMonthPerRow : 3,<br>markWeekends: false,<br>pageKeyWarp: 3,<br>allowedDates: [...see source...]'
			},
			menu	: datepickerplusmenu_2
		},
		'-',
		{
			text	: 'DateMenu 3',
			tooltip	: {
				title:'DateMenu Example 3',
				text:'Multimonth (2x2), Multiselection (without the need of pressing CTRL!), Max Selection Days of 10, Weekends with Quicktips, Weeknumbers, No Holidays, Custom CSS, Quicktips, No Ok-Undo Buttons although Multiselection is activated!, Unselect days of weeks of Months when parts of them are still selected<hr>noOfMonth : 4,<br>noOfMonthPerRow : 2,<br>multiSelection: true,<br>multiSelectByCTRL:false,<br>maxSelectionDays: 10,<br>markNationalHolidays: false,<br>renderOkUndoButtons:false,<br>disablePartialUnselect:false,<br>eventDate: function...(see source for detail)'
			},
			menu	: datepickerplusmenu_3
		},
		'-',
		{
			text	: 'DateMenu 4',
			tooltip	: {
				title:'DateMenu Example 4',
				text:'Single Month, Multiselection, Weekends, Weeknumbers, Selectable Days between April and July 2008, Only Range Selection without gaps allowed<hr>noOfMonth : 1,<br>multiSelection: true,<br>strictRangeSelect: true,<br>minDate: new Date(2008, 3, 1),<br>maxDate: new Date(2008, 6, 31)'
			},
			menu	: datepickerplusmenu_4
		},
		'-',
		'DateFieldPlus 1:',
		{
			xtype: 'datefieldplus',
//			id:'dptest',
			allowBlank:false,
			editable:false,	//Ext 3
			readonly: extMajorVersion<=2,
			markWeekends:false,
			markNationalHolidays:false,
			showWeekNumber:false,
			width:85,
			showPrevNextTrigger:true,
			tooltip	: {
				title:'DateField Example 1',
				text:'Single Month, No Multiselection, No Weekends, No Weeknumbers, No Holidays, quicktips, prevNext Day Buttons<hr>showWeekNumber: false,<br>markNationalHolidays: false,<br>markWeekends : false<br>showPrevNextTrigger : true'
			},
			listeners: {
				select: function(dp,date) {
					var allStringDates=[];
					if (Ext.isDate(date)) {
						allStringDates.push(date.format('M j, Y'));
					}
					else {
						Ext.each(date,function(c){
							allStringDates.push(c.format('M j, Y'));
						},this);
					}
					
					Ext.MessageBox.alert('Date(s) Selected', 'You have chosen the following day(s):<br>'+allStringDates.join('<br>'));
				}
			}
		},
		'-',
		'DateFieldPlus 2:',
		{
			xtype: 'datefieldplus',
			allowBlank:false,
//			readOnly:true,
			showWeekNumber: true,
			noOfMonth : 3,
			noOfMonthPerRow : 1,
			useQuickTips:false,
			width:110,
			multiSelection:true,
			value: [new Date(2011,4,8),new Date(2011,4,11)],
			
			tooltip	: {
				title:'DateFieldPlus Example 2',
				text:'Multimonth (1x3), Multiselection, Weekends, Weeknumbers, Custom CSS, Holidays, Browserbased Tooltips<hr>showWeekNumber: true,<br>noOfMonth : 3,<br>noOfMonthPerRow : 1<br>multiSelection:true,<br>useQuickTips:false'
			},
			listeners: {
				select: function(dp,date) {
					var allStringDates=[];
					if (Ext.isDate(date)) {
						allStringDates.push(date.format('M j, Y'));
					}
					else {
						Ext.each(date,function(c){
							allStringDates.push(c.format('M j, Y'));
						},this);
					}
					
					Ext.MessageBox.alert('Date(s) Selected', 'You have chosen the following day(s):<br>'+allStringDates.join('<br>'));
				}
			}
			
		},
		'-',
		'DateFieldPlus 3:',
		{
			xtype: 'datefieldplus',
			allowBlank:false,
			editable:false,	//Ext 3			
			readonly: extMajorVersion<=2,
			showWeekNumber: true,
			disableMonthPicker:true,
//			renderPrevNextButtons:false,
			renderPrevNextYearButtons:true,
			showActiveDate:true,
			disabledLetter: "X",
			value: new Date(2011,4,8),
			minDate: new Date(2011, 4, 5),
			maxDate: new Date(2011, 4, 26),			
			width:85,

			tooltip	: {
				title:'DateFieldPlus Example 3',
				text:'Single Month, no MonthPicker, PrevNext Year Buttons, Active Date Keynavigation, Mark disabled Dates with X,Weekends, Weeknumbers, Holidays<hr>disableMonthPicker:true,<br>renderPrevNextYearButtons:true,<br>showActiveDate:true,<br>disabledLetter: "X",<br>showWeekNumber: true'
			}
		},
		'->',
		'Ext v',
		new Ext.form.ComboBox({
			store:new Ext.data.SimpleStore({
				id:"extv",
				fields: ['extv'],
				data : [
					["3.3.1"],
					["3.2.1"],
					["2.3.0"]
				]
			}),
			value: "3.3.1",
			currentVal: "3.3.1",
			editable: false,
			triggerAction : 'all',
			displayField:'extv',
			valueField:'extv',			
			mode: 'local',
			width:75,
			listeners: {
				select: function(c) {
					reload_wholepage('&extv='+c.getValue()+'&lang='+jslang);
				}
			}
		}),		
		new Ext.CycleButton({
			tooltip: LBRSTR__LANGUAGE_SELECTION,
			items: [
				{
					id: "lang_EN",						
					text: LBRSTR__ENGLISH,
					iconCls: 'flag_en',
					checked: (jslang=="EN"?true:false)						
				},
				{
					id: "lang_DE",
					text: LBRSTR__GERMAN,
					iconCls: 'flag_de',
					checked: (jslang=="DE"?true:false)
				},
				{
					id: "lang_RU",
					text: LBRSTR__RUSSIAN,
					iconCls: 'flag_ru',
					checked: (jslang=="RU"?true:false)						
				},
				{
					id: "lang_IT",
					text: LBRSTR__ITALIAN,
					iconCls: 'flag_it',
					checked: (jslang=="IT"?true:false)						
				},
				{
					id: "lang_NL",
					text: LBRSTR__DUTCH,
					iconCls: 'flag_nl',
					checked: (jslang=="NL"?true:false)
				},
				{
					id: "lang_FR",
					text: LBRSTR__FRENCH,
					iconCls: 'flag_fr',
					checked: (jslang=="FR"?true:false)
				},
				{
					id: "lang_NO",
					text: LBRSTR__NORWEGIAN,
					iconCls: 'flag_no',
					checked: (jslang=="NO"?true:false)
				},
				{
					id: "lang_ES",
					text: LBRSTR__SPANISH,
					iconCls: 'flag_es',
					checked: (jslang=="ES"?true:false)
				},
				{
					id: "lang_RO",
					text: LBRSTR__ROMANIAN,
					iconCls: 'flag_ro',
					checked: (jslang=="RO"?true:false)
				},
				{
					id: "lang_JP",
					text: LBRSTR__JAPANESE,
					iconCls: 'flag_jp',
					checked: (jslang=="JP"?true:false)
				},
				{
					id: "lang_PL",
					text: LBRSTR__POLISH,
					iconCls: 'flag_pl',
					checked: (jslang=="PL"?true:false)
				}
			],
		
			changeHandler:function(btn, item){
				reload_wholepage('&'+item.id.replace(/_/,"=")+'&extv='+jsextv);
			}		
		})
		
	]);
	


	var dWin = new Ext.Window({
		title	:LBRSTR__WINDOW_TITLE,
		closable: false,
		draggable:false,
		resizable:false,
		width	: Ext.lib.Dom.getViewWidth()-50,
		height	: Ext.lib.Dom.getViewHeight()-50,
		x:25,
		y:25,
		constrain:true,
		layout:'border',
		tbar: datepickerplus_features,		
		items: [
			{
				contentEl: 'content',
				region:'west',
				layout: 'fit',
				autoScroll:true,
				width:550,
				minWidth:450,
				split: true				
			},
			{
				region:'center',
				layout: 'fit',
				autoScroll:true,				
				items: [
				{
					xtype: 'datepickerplus',
//					disabled:true,
					value: new Date(2011, 3, 30),	//only the month counts here and is used as starting month to be displayed
					noOfMonth : 4, //(Ext.lib.Dom.getViewHeight()>600?9:4), //9 ,
					noOfMonthPerRow : (Ext.lib.Dom.getViewWidth()>1024?3:2), //4,
					multiSelection: true,
//					allowMouseWheel:false,
					showWeekNumber: true,
					weekendText: LBRSTR__WEEKENDTEXT,
//					disabledDates: [new Date(2008,4,5).format(dform).replace(/\./g,"\\."),new Date(2008,4,6).format(dform).replace(/\./g,"\\."),new Date(2008,4,7).format(dform).replace(/\./g,"\\.")],
					showActiveDate:true,
					summarizeHeader:true,
//					prevNextDaysView:"nomark",
//					prevNextDaysView:false,
					listeners: {
						select: function(dp,date) {
							var allStringDates=[];
							if (Ext.isDate(date)) {
								allStringDates.push(date.format('M j, Y'));
							}
							else {
								Ext.each(date,function(c){
									allStringDates.push(c.format('M j, Y'));
								},this);
							}
							
							Ext.MessageBox.alert('Date(s) Selected', 'You have chosen the following day(s):<br>'+allStringDates.join('<br>'));
						}
					},
					eventDates : function(year) {
						var dates = [
						{
							date: new Date(year,4,14),
							text: "My cat died "+(year-2001)+" years ago",
							cls: "x-datepickerplus-eventdates"
						},
						{
							date: new Date(year,10,5),
							text: "My 2nd cat died "+(year-2008)+" years ago",
							cls: "x-datepickerplus-eventdates"
						},
						{
							date: new Date(year,4,31),
							text: "My 3rd cat died "+(year-2009)+" years ago",
							cls: "x-datepickerplus-eventdates"
						},
									 
						{
							date: new Date(year,4,11), 
							text: "May 11th, Author's Birthday (Age:"+(year-1973)+")",
							cls: "x-datepickerplus-eventdates"									
						}
								
						];
						return dates;
					}
				}
				]
			}
		]

	});

	
	dWin.show();
	
	window.onresize = function() {
		dWin.setPosition(25,25);
		dWin.setSize(Ext.lib.Dom.getViewWidth()-50, Ext.lib.Dom.getViewHeight()-50);
	};

	setTimeout(function(){
		Ext.get('loading').remove();
		Ext.get('loading-mask').fadeOut({
			remove:true
		});
	}, 250);
});

</script>