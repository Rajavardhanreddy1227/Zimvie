@isTest(seeAllData=true)
public class B2B_AutoSearchIndexSchedulerTest {
    // Test method to cover the scheduled job
    static testMethod void testScheduledJob() {
        // Create test data, e.g., a WebStore record with the required name
        WebStore testWebStore = new WebStore(Name = 'Zimvie');
        insert testWebStore;
        
        // Schedule the job
        Test.startTest();
        B2B_AutoSearchIndexScheduler myClass = new B2B_AutoSearchIndexScheduler ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test B2B_AutoSearchIndexScheduler', chron, myClass);
        system.schedule('Test B2B_AutoSearchIndexScheduler2', chron, myClass);
        Test.stopTest();
    }
}