@isTest
private class B2BOrderSummarySelectorTest {

    @testSetup
    static void createMockData() {
        // Create mock data for testing here.
        // You need to insert OrderSummary, OrderItemSummary, and OrderDeliveryGroupSummary records
        // with related fields.
        // For example:
           Map<String,String> response = B2B_TestUtils.initialStorefrontSetup();
            String accId = response.get('accountId');
        	String conId = response.get('contactId');
        	String prodId = response.get('productId');
        	String pbId = response.get('pricebookId');
        	String pricebookEntryId = response.get('pricebookEntryId');

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

    OrderDeliveryMethod orderDeliveryMethod = new OrderDeliveryMethod(
      Name = 'software-shipping',
      ProductId = prodId
    );
    insert orderDeliveryMethod;

    OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup(
      DeliverToName = 'Buyer USer',
      DeliverToStreet = 'test Street',
      DeliverToCity = 'Minneapolis',
      DeliverToState = 'New York',
      DeliverToPostalCode = '55402',
      DeliverToCountry = 'United States',
      OrderDeliveryMethodId = orderDeliveryMethod.Id,
      OrderId = o.Id
    );
    insert orderDeliveryGroup;

//    Product2 productShipping = TestUtils.createProduct('shipping');
//    insert productShipping;

     OrderItem orderItem = new OrderItem(
      Product2Id = prodId,
      Type = 'Order Product',
      Quantity = 1,
      ListPrice = 1020,
      UnitPrice = 1020,
      OrderId = o.Id,
      OrderDeliveryGroupId = orderDeliveryGroup.Id,
      PricebookEntryId = pricebookEntryId,
      TotalLineAmount = 1
    );
    insert orderItem;

    o.Status = 'Activated';
    update o;
    }

    @isTest
    static void testGetOrderSummary() {
        Map<String, Object> dataMap = new Map<String, Object>{
            B2BConstants.ORDER_SUMMARY_NUMBER => 'TestOrderNumber' // Use the test order number you've created
        };

        List<OrderSummary> orders = B2BOrderSummarySelector.getOrderSummary(dataMap);
    }

    @isTest
    static void testGetOrderProductSummary() {
        Map<String, Object> dataMap = new Map<String, Object>{
            B2BConstants.ORDER_SUMMARY_NUMBER => 'TestOrderNumber' // Use the test order number you've created
        };

        List<OrderItemSummary> items = B2BOrderSummarySelector.getOrderProductSummary(dataMap);
    }

    @isTest
    static void testGetOrderDeliveryGroupSummary() {
        Map<String, Object> dataMap = new Map<String, Object>{
            B2BConstants.ORDER_SUMMARY_NUMBER => 'TestOrderNumber' // Use the test order number you've created
        };

        List<OrderDeliveryGroupSummary> deliveries = B2BOrderSummarySelector.getOrderDeliveryGroupSummary(dataMap);
    }
}