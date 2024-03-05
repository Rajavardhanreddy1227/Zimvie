public with sharing class GplCreateProfileFromContactController {
    private final Contact contact;
    public GPL_Profile__c profile { get; set; }
    public GPL_Location__c location { get; set; }

       public GplCreateProfileFromContactController(ApexPages.StandardController stdController)
       {
        contact = (Contact)stdController.getRecord();
        Id id = contact.Id;
        profile = null;
        list<GPL_Profile__c> profiles = [SELECT Id, Name__c, FirstName__c, Inactive__c, LastName__c, Contact__c, Specialty_Type__c FROM GPL_Profile__c WHERE Contact__c = :id LIMIT 1];
        if ((profiles != null) && (!profiles.isEmpty()))
        {
            profile = profiles.get(0);
        }
        System.debug('------------------ LEAVE Constructor---------------------');
      }
    
    public PageReference back()
    {
        return new ApexPages.Standardcontroller(contact).view();
    }
    
    public PageReference init()
    {
        System.debug('------------------ IN Init()---------------------');
        if (profile != null)
        {
            PageReference profilePage = new ApexPages.Standardcontroller(profile).view(); 
            profilePage.setRedirect(true);
            return profilePage;
        } else {
            return null;
        }
    }
    
    public PageReference create()
    {
        profile = null;
        Id id = contact.Id;
        
        Contact c = [SELECT Id, RecordTypeId, Salutation, FirstName, LastName, GPL_Profile__c, Physicians_Locator__c,
         MailingCity, MailingCountry, Fax, Name, Phone, MailingPostalCode, MailingStreet, MailingState, Website__c, Specialty_Type__c FROM Contact WHERE Id = :id];
         
        profile = GplProfileBuilder.buildProfile(c);
        try{
            insert profile;
        }
        catch(Exception e)
        {
                ApexPages.addMessages(e);
        }
         
        location= GplProfileBuilder.buildlocation(c);
        location.GPL_Profile__c=profile.Id;
        
        try{
            insert location;
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        } 
        c.GPL_Profile__c=profile.Id;
        c.Physicians_Locator__c=true;
        
        try{
        update c;   
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
        }
         
        PageReference profilePage = new ApexPages.StandardController(profile).view();
        profilePage.setRedirect(true);
        return profilePage;
    }
    /*
    static testMethod void testGplCreateProfileFromContactController()
    {
        Id hospitalAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Healthcare Facility');
        Account account = new Account(
            RecordTypeId = hospitalAccountTypeId,
            Name = 'Test Hospital',
            ShippingStreet = 'TEST 789 Maple St',
            ShippingCity = 'Puerto Villamil',
            ShippingState = 'EC',
            ShippingPostalCode = 'EC012001',
            ShippingCountry = 'EC'
        );
        insert(account);
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Salutation = 'Dr.'
        );
        PageReference pageRef = Page.GplCreateProfileFromContactPage;
        insert(contact);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        GplCreateProfileFromContactController controller = new GplCreateProfileFromContactController(sc);
        System.assertEquals(null, controller.init());
        controller.create();
        System.assertNotEquals(null, controller.profile);
        System.assertNotEquals(null, controller.init());
    }
    
*/
}