@isTest
Private class Test_Distributor_Locater_Updated 
{
    static testmethod void testwebservice()
    {
        
        Zip_codes_distributor__c zci= new Zip_codes_distributor__c();
        zci.name='123456';
        insert zci;
        
        territory__c t=new territory__c();
        t.Name='teritory';
        insert t;
        
        County_Distributor__c cdc=new County_Distributor__c();
        cdc.Name='xyz';
        //cdc.Zip_Codes_Distributor__c=zci.Id;
        insert cdc;
        
        Territory_county__c tc=new Territory_county__c();
        tc.County_Distributor__c=cdc.Id;
        tc.territory__c=t.Id;
        tc.County_Distributor__c=cdc.Id;
        insert tc;
        
        //RecordType rtype=[select Id from RecordType where Name=:'Distributor'];
        RecordType rtype=[select Id from RecordType where DeveloperName=:'Distributor'];
        Account a=new Account();
        a.Name='testacct';
        a.RecordTypeId=rtype.Id;
        a.BillingCity='NewArk';
        a.Website='www.google.com';
        a.BillingState='CA';
        a.BillingPostalCode='123456';
        a.BillingStreet='asdf';
        a.BillingCountry='CA';
        a.territory__c=t.Id;
        a.Organization__c = 'Parent';
        insert a;
        
       
        
    //  Territory_county__c
        County_to_Zip_codes__c czc=new County_to_Zip_codes__c();
        
        Distributor_Locater_Updated.Distributor_Locator_Output subclass=new Distributor_Locater_Updated.Distributor_Locator_Output();
        subclass.ZipCodeOrPostalCode='123456';
        Distributor_Locater_Updated.zipCodeMethod('123456');
        Distributor_Locater_Updated.countryMethod('china');
        Distributor_Locater_Updated.MySalesAssociate(a.Id);
        
    }
}