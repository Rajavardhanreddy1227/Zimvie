public with sharing class GdlManageWebsiteController { 
	private final Account account;
	private GDL_Profile__c profile;
	public list<Account> locations {get;set;}
	public list<EventListItem> events {get;set;}
	public list<LinkListItem> links {get;set;}
	public GDL_DistributorLink__c newLink {get;set;}
	public GDL_DistributorEvent__c newEvent {get;set;}
	public String lastSaved {get;set;}
	public String todaysDate {get;set;}
	private list<GDL_DistributorLink__c> deletedLinks = new list<GDL_DistributorLink__c>();
	private list<GDL_DistributorLink__c> addedLinks = new list<GDL_DistributorLink__c>();
	private list<GDL_DistributorEvent__c> deletedEvents = new list<GDL_DistributorEvent__c>();
	private list<GDL_DistributorEvent__c> addedEvents = new list<GDL_DistributorEvent__c>();
	
	public GDL_Profile__c getProfile(){
		return profile;
	}
	
	public GdlManageWebsiteController(ApexPages.StandardController stdController){
		System.debug('------------------IN CONSTRUCTOR---------------------');
		//String id = ApexPages.currentPage().getParameters().get('id');
		String id = stdController.getRecord().Id;
		system.debug('id' + id);
		profile = [SELECT Id, Name__c, Content__c, Image__c, Account__c, LastModifiedDate, Account__r.Id FROM GDL_Profile__c WHERE Id = :id];
		list<GDL_DistributorEvent__c> eventObjs = [SELECT Id, Name,Title__c, StartDate__c, EndDate__c, Description__c FROM GDL_DistributorEvent__c WHERE DistributorProfile__c = :id];
		events = new list<EventListItem>();
		for (Integer i=0;i<eventObjs.size();i++){
			GDL_DistributorEvent__c e = eventObjs.get(i);
			events.add(new EventListItem(e, i));
		}
		list<GDL_DistributorLink__c> linkObjs = [SELECT Id, Name,Title__c, Target__c FROM GDL_DistributorLink__c WHERE DistributorProfile__c = :id];
		links = new list<LinkListItem>();
		for (Integer i=0;i<linkObjs.size();i++){
			GDL_DistributorLink__c l = linkObjs.get(i);
			links.add(new LinkListItem(l,i));
		}
		locations = [SELECT Name FROM Account WHERE (Id = :profile.Account__r.Id OR ParentId = :profile.Account__r.Id)
												AND (Deactive_Date__c = null OR Deactive_Date__c > TODAY)];
		newLink = new GDL_DistributorLink__c();
		newEvent = new GDL_DistributorEvent__c();
		lastSaved = profile.LastModifiedDate.format('MM/dd/yyyy hh:mm:ss a z', 'GMT');
		todaysDate = Datetime.now().format('MM/dd/yyyy', 'GMT');
	}
	
	public PageReference save(){
		System.debug('----------------------IN SAVE-------------------------');
		try {
			update(profile);
			if (deletedLinks.size() > 0){
				delete deletedLinks;
				deletedLinks = new list<GDL_DistributorLink__c>();
			}
			if (addedLinks.size() > 0){
				insert addedLinks;
				addedLinks = new list<GDL_DistributorLink__c>();
			}
			if (deletedEvents.size() > 0){
				delete deletedEvents;
				deletedEvents = new list<GDL_DistributorEvent__c>();
			}
			if (addedEvents.size() > 0){
				insert addedEvents;
				addedEvents = new list<GDL_DistributorEvent__c>();
			}
			lastSaved = Datetime.now().format('MM/dd/yyyy hh:mm:ss a z', 'GMT');
		} catch (DMLException e){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error saving content'));
		}
		return null;
	}
	
	public PageReference addLink(){
		newLink.DistributorProfile__c = profile.Id;
		addedLinks.add(newLink);
		Integer index = events.size();
		links.add(new LinkListItem(newLink, index));
		//update index?
		newLink = new GDL_DistributorLink__c();
		return null;
	}
	
	public PageReference removeLink(){
		String index = System.currentPageReference().getParameters().get('index');
		GDL_DistributorLink__c l = links.get(Integer.valueOf(index)).link;
		if (l.Id == null){
			for (Integer i=0;i<addedlinks.size();i++){
				GDL_DistributorLink__c added = addedLinks.get(i);
				if (l.Title__c == added.Title__c){
					addedLinks.remove(i);
					break;
				}
			}		
		}else {
			deletedLinks.add(l);
		}
		links.remove(integer.valueOf(index));
		for (Integer i=0; i<links.size();i++){
			links.get(i).index = i;
		}
		return null;
	}
	
	public PageReference addEvent(){
		newEvent.DistributorProfile__c = profile.Id;
		addedEvents.add(newEvent);
		Integer index = events.size();
		events.add(new EventListItem(newEvent, index));
		//update index?
		newEvent = new GDL_DistributorEvent__c();
		return null;
	}
	
	public PageReference removeEvent(){
		String index = System.currentPageReference().getParameters().get('index');
		GDL_DistributorEvent__c e = events.get(integer.valueOf(index)).event;
		if (e.Id == null){ // need to remove it from added links
			for (Integer i = 0; i < addedEvents.size();i++){
				GDL_DistributorEvent__c added = addedEvents.get(i);
				if (e.Title__c == added.Title__c){
					addedEvents.remove(i);
					break;
				}
			}
		}else {//need to add it to deletedLinks
			deletedEvents.add(e);
		}		
		events.remove(integer.valueOf(index));	
		for (Integer i=0; i<events.size();i++){
			events.get(i).index = i;
		}
		//update indexes
		return null;
	}
	
	public class EventListItem {
		public GDL_DistributorEvent__c event {get;set;}
		public Integer index {get;set;}
		public EventListItem(GDL_DistributorEvent__c e, Integer i) {
			event = e;
			index = i;
		}
	}
	
	
	public class LinkListItem {
		public GDL_DistributorLink__c link {get;set;}
		public Integer index {get;set;}
		public LinkListItem(GDL_DistributorLink__c l, Integer i) {
			link = l;
			index = i;
		}
	}
	
	static testmethod void testController(){	
		Id RECORD_TYPE_ID = RecordTypeHelper.getRecordTypeId('Account','Distributor');	
    	Account main = new Account(
    		RecordTypeID = RECORD_TYPE_ID,
    		Name = 'Test Parent Distributor',
    		BillingStreet = 'TEST 123 Main Street',
    		BillingCity = 'Easter Island',
    		BillingState = 'CL',
    		BillingPostalCode = 'CL012001',
    		BillingCountry = 'CL',
    		Latitude__c = -27.128,
    		Longitude__c = -109.341,
    		Territory_Number__c = '0000',
    		Organization__c = 'Parent'
    		//Territory__c = '0000'	
    	);
    	insert(main);
    	Account s1 = new Account(
    		RecordTypeId = RECORD_TYPE_ID,
    		ParentId = main.Id,
    		Name = 'Test Satellite Distributor',
    		BillingStreet = 'TEST 123 Main Street',
    		BillingCity = 'Puerto Villamil',
    		BillingState = 'EC',
    		BillingPostalCode = 'EC012001',
    		BillingCountry = 'EC',
    		Latitude__c = -0.8292784,
    		Longitude__c = -90.9820667999999,
    		Territory_Number__c = '0000',
    		Organization__c = 'Satellite'
    		//Territory__c = '0000'
    	);
    	insert(s1);
    	GDL_Profile__c profile = new GDL_Profile__c(
    		Account__c = main.Id,
    		Content__c = '<h3>About Test Parent Distributor</h3><p>This is the content for this distributor</p>',
    		Image__c = 'image1'    		
    	);
    	insert(profile);
    	GDL_DistributorLink__c link = new GDL_DistributorLink__c(
    		Target__c = 'http://www.google.com',
    		Title__c = 'Google',
    		DistributorProfile__c = profile.Id
    	);
    	insert(link);
    	GDL_DistributorEvent__c event = new GDL_DistributorEvent__c(
    		Title__c = 'A Test Event',
    		StartDate__c = System.today(),
    		EndDate__C = System.today(),
    		DistributorProfile__c = profile.Id
    	);
    	insert(event);
    	PageReference pageRef = Page.GdlEditProfile;
    	Test.setCurrentPage(pageRef);
    	ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(profile);
    	GdlManageWebSiteController ext = new GdlManageWebSiteController(sc);
    	ext.newEvent.StartDate__c = Date.today();
    	ext.newEvent.EndDate__c = Date.today();
    	ext.newEvent.Title__c = 'Test Event';
    	ext.newEvent.Description__c = 'Description for a test event.';
    	System.assertEquals(null,ext.addEvent());
    	ext.newLink.Title__c = 'Google';
    	ext.newLink.Target__c = 'http://www.google.com';
    	System.assertEquals(null,ext.addLink());
    	System.assertEquals(null,ext.save());
    	ApexPages.currentPage().getParameters().put('index','0');
    	System.assertEquals(null,ext.removeLink());
    	ApexPages.currentPage().getParameters().put('index','0');
    	System.assertEquals(null,ext.removeEvent());
    	
	}
	
}