@isTest
public class SubmitBatchCreateFulfillmentOrdersTest {

    @isTest
    static void testExecute() {
        Test.startTest();
        SubmitBatchCreateFulfillmentOrders scheduler = new SubmitBatchCreateFulfillmentOrders();
        scheduler.execute(null); 
        Test.stopTest();
    }
}