@isTest
public class b2B_CustomAddressComponentControllerTest {
    @TestSetup
    public static void testSetupData()
    {
        
        Map<String, String> setupData= B2B_TestUtils.initialStorefrontSetup();
        
        B2B_TestUtils.createFavAddress(setupData.get('contactId'),setupData.get('con_point_shippingId'));
        B2B_TestUtils.setDefaultAddress(setupData.get('con_point_shippingId'),setupData.get('contactId'));
    }
    @isTest
    static void testRemoveFav() {
        // Create test data
        Favorite_Address__c cp = [SELECT Id FROM Favorite_Address__c LIMIT 1];
        User u = [SELECT Id FROM User LIMIT 1];
        System.runAs(u)
        {
            Test.startTest();
            // Call the removeFav method
            b2B_CustomAddressComponentController.removeFav(cp.Id);
            b2B_CustomAddressComponentController.removeFav(null);
            Test.stopTest();
        }
        
        // Add assertions to verify the expected behavior
    }
    
    @isTest
    static void testAddFav() {
        // Create test data
        ContactPointAddress cp = [SELECT Id FROM ContactPointAddress LIMIT 1];
        User u = [SELECT Id FROM User LIMIT 1];
        System.runAs(u)
        {
            Test.startTest();
            // Call the addFav method
            b2B_CustomAddressComponentController.addFav(cp.Id);
            b2B_CustomAddressComponentController.addFav(null);
            Test.stopTest();
        }
        
        // Add assertions to verify the expected behavior
    }
    
    @isTest
    static void testAddDefault() {
        // Create test data
        ContactPointAddress cp = [SELECT Id FROM ContactPointAddress LIMIT 1];
        User u = [SELECT Id FROM User LIMIT 1];
        System.runAs(u)
        {
            Test.startTest();
            // Call the addDefault method
            b2B_CustomAddressComponentController.addDefault(cp.Id);
            b2B_CustomAddressComponentController.addDefault(null);
            Test.stopTest();
        }
        
        // Add assertions to verify the expected behavior
    }
    
    @isTest
    static void testFetchAddressRecords() {
        // Create test data
        ContactPointAddress cp = [SELECT Id FROM ContactPointAddress LIMIT 1];
        cp.ActiveToDate = system.today();
        update cp;
        Id accId = [Select Id from Account where Name='Test Name' limit 1].Id;
        User u = [SELECT Id FROM User LIMIT 1];
        System.runAs(u)
        {
            Test.startTest();
            // Call the fetchAddressRecords method
            String result = b2B_CustomAddressComponentController.fetchAddressRecords(accId);
            String result1 = b2B_CustomAddressComponentController.fetchAddressRecords(null);
            Test.stopTest();
            
            
            // Add assertions to verify the expected behavior and deserialize the result
            System.assertNotEquals(null, result, 'Favorite addresses should not be null');
        }
        // Add more assertions as needed
    }
    
    @isTest
    static void testFetchCheckoutAddressRecords() {
        // Create test data
        
        ContactPointAddress cp = [SELECT Id FROM ContactPointAddress LIMIT 1];
        cp.ActiveToDate = system.today();
        update cp;
        Id accId = [Select Id from Account where Name='Test Name' limit 1].Id;
        User u = [SELECT Id FROM User LIMIT 1];
        System.runAs(u)
        {
            Test.startTest();
            // Call the fetchCheckoutAddressRecords method
            Id crtId = [Select Id from Webcart limit 1].Id;
            B2B_POCommentsController.savePoCommentsOnCart(crtId, 'sfdsfdsf');
            String result = b2B_CustomAddressComponentController.fetchCheckoutAddressRecords(accId,crtId);
            String result1 = b2B_CustomAddressComponentController.fetchCheckoutAddressRecords(null,null);
            Test.stopTest();
            
            // Add assertions to verify the expected behavior and deserialize the result
            System.assertNotEquals(null, result, 'Favorite addresses should not be null');
        }
        // Add more assertions as needed
    }
}