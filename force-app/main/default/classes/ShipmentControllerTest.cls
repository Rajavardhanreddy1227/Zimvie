@isTest
private class ShipmentControllerTest {
	@isTest
    static void getShipmentsTest(){
        Map<String,String> response = B2B_TestUtils.initialStorefrontSetup();
        String accId = response.get('accountId');
        String conId = response.get('contactId');
        Order o = new Order(
            EffectiveDate = Date.today(),
            Status = 'Draft',
            AccountId = accId,
            BillToContactId = conId,
            BillingCountry = 'United States',
            OrderedDate = System.now(),
            Pricebook2Id = System.Test.getStandardPricebookId()
        );
        insert o;
        Test.startTest();
    ShipmentController.getShipments(o.Id);
    Test.stopTest();
}
}