@isTest
Private class test_Services_Inventory {
    
    static testmethod void testwebservice()
    {
        Services_Inventory.Physician_Locator_Output subclass=new Services_Inventory.Physician_Locator_Output();
        List<string> ziplist=new list<string>();
        ziplist.add('12345');
        //ziplist.add('1234');
        
        //RecordType rtype=[select Id from RecordType where Name='Medical Practice'];
        RecordType rtype=[select Id from RecordType where DeveloperName='Practice'];
        Account a=new Account();
        a.Name='testacct';
        a.RecordTypeId=rtype.Id;
        a.BillingCity='NewArk';
        a.Website='www.google.com';
        a.BillingState='CA';
        a.BillingPostalCode='123456';
        a.BillingStreet='asdf';
        a.BillingCountry='CA';
        a.ShippingPostalCode='12345';
        a.ShippingCountry='CA';
        a.Specialty_integration__c='brain';
        a.Physicians_Locator__c=true;   
        
        //a.territory__c=t.Id;
        insert a;
        System.Debug(a);
        Account a1=new Account();
        a1.FirstName='FirstName';
        a1.LastName='testacct1';
        a1.RecordTypeId=RecordTypeHelper.getRecordTypeId('Account','Physician');
        a1.BillingCity='NewArk';
        a1.Website='www.google.com';
        a1.BillingState='AB';
        a1.BillingPostalCode='123456';
        a1.BillingStreet='asdf';
        a1.BillingCountry='CA';
        a1.ShippingPostalCode='12345';
        a1.ShippingCountry='CA';
        a1.ShippingState='AB';
        a1.Specialty_integration__c='brain';
        a1.Physicians_Locator__c=true;
        a1.PersonMailingCountry='CA';
        a1.Physician_Specialty__c='brain';  
        a1.PersonMailingState ='AB';   
        a1.PersonMailingCity ='AB';
        a1.PersonMailingPostalCode='12345';
        a1.PersonMailingStreet ='asdg';
        insert a1;
        System.Debug(a1);
        Practice_Surgeon_Link__c psl=new Practice_Surgeon_Link__c();
        psl.Practice__c=a.Id;
        psl.Surgeon__c=a1.Id;
        insert psl;
        
        
        
        Practice_Surgeon_Link__c psl1=new Practice_Surgeon_Link__c();
        psl1.Practice__c=a.Id;
        psl1.Surgeon__c=a1.Id;
        Insert psl1;
        
        Phy_Country_Codes__c pcc=new Phy_Country_Codes__c();
        pcc.Name='150';
        pcc.Condition_Code__c='brain';
        insert pcc;
        Services_Inventory.zipCodeMethod(ziplist, 150);
        Services_Inventory.StateCountryMethod('CA', 'CA', 150);
        Services_Inventory.MyPhysicianMethod(psl.Id, psl.Id);   
    }
}