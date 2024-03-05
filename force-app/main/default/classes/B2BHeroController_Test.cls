@isTest
public class B2BHeroController_Test {
    @TestSetup
    public static void testSetupData()
    {
        B2B_TestUtils.initialStorefrontSetup();
    }
    @isTest
    static void testRetrieveMediaFromCMS() {
        // Test data setup
        // You might need to create test data or mocks for ConnectApi.ManagedContent and ConnectApi.ManagedContentVersionCollection

        // Call the method
        Test.startTest();
        String result = B2BHeroController.retrieveMediaFromCMS();
        Test.stopTest();

        // Assertions
        System.assert(result == null, 'Result should not be null');
        // Add more assertions based on your expected results
    }

    @isTest
    static void testGetChannelId() {
        // Test data setup
        // You might need to create test data or mocks for ConnectApi.ManagedContentChannelCollection and ConnectApi.ManagedContentChannel

        // Call the method
        Test.startTest();
        String channelName = 'TestChannel'; // Replace with your test channel name
        String result = B2BHeroController.getChannelId(channelName);
        Test.stopTest();

        // Assertions
        System.assert(result == null,'Result should be null or start with 0M');
        // Add more assertions based on your expected results
    }
    
}