@isTest
private class ZMVE_ReturnsOrders_Test {

    @isTest
    static void testReturnOrder() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test Order Summary
        OrderSummary testOrderSummary = new OrderSummary(AccountId = testAccount.Id);
        insert testOrderSummary;

        // Create test Order Item Summary
        OrderItemSummary testOrderItemSummary = new OrderItemSummary(OrderSummaryId = testOrderSummary.Id);
        insert testOrderItemSummary;

        // Set up the mock for ConnectApi.OrderSummary class
        Test.startTest();
		ZMVE_ReturnsOrders.returnOrder();
        Test.stopTest();
    }
}