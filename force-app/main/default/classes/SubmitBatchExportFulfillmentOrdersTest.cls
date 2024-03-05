@isTest
public class SubmitBatchExportFulfillmentOrdersTest {

    @isTest
    static void testExecute() {
        // Start Test
        Test.startTest();

        // Create an instance of the Schedulable class
        SubmitBatchExportFulfillmentOrders scheduler = new SubmitBatchExportFulfillmentOrders();

        // Execute the Schedulable class
        scheduler.execute(null); // Pass null for SchedulableContext since we don't need it

        // Verify the behavior and results as needed
        // For example, you can query the AsyncApexJob object to check if the batch job was created

        // End Test
        Test.stopTest();
    }
}