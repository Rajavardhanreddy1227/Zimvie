@isTest
public class GdlLocatorServiceTest {

    private static Id RECORD_TYPE_ID = RecordTypeHelper.getRecordTypeId('Account','Distributor');    
    
    static testmethod void testSearchLocations() {
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
            Name = 'Test Parent Distributor',
            BillingStreet = 'TEST 123 Main Street',
            BillingCity = 'Puerto Villamil',
            BillingState = 'EC',
            BillingPostalCode = 'EC012001',
            BillingCountry = 'EC',
            Latitude__c = -0.8292784,
            Longitude__c = -90.9820667999999,
            Territory_Number__c = '0000',
            Organization__c = 'Parent'
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
        
        GdlDataModel.SearchCriteria criteria = new GdlDataModel.SearchCriteria();
        criteria.country = 'CL';
        criteria.state = 'CL';
        criteria.postalCode = 'CL012001';
        test.startTest();
            list<GdlDataModel.DistributorLocation> locations = GdlLocatorService.searchLocations(criteria);
            System.assertEquals(1, locations.size());
            GdlDataModel.DistributorProfile prof = GdlLocatorService.getDistributorProfile(locations.get(0).Id);
            System.assertNotEquals(null, prof);
        test.stopTest();
        
    }

}