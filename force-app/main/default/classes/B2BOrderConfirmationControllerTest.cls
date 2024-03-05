@isTest
public class B2BOrderConfirmationControllerTest {
 	@testSetup
    static void createMockData() {
        
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
    static void testGetOrderProductSummary() {
        Map<String, Object> dataMap = new Map<String, Object>{
            B2BConstants.ORDER_SUMMARY_NUMBER => 'TestOrderNumber' // Use the test order number you've created
        };

        Map<String,Object> prodSummaryResult = B2BOrderConfirmationController.getOrderProductSummary(dataMap);
        B2BOrderConfirmationController.getOrderProductSummary(null);
        System.assertNotEquals(0, prodSummaryResult.size(), 'Order summaries should not be empty.');
    }

    @isTest
    static void testGetAddressInformation() {
        Map<String, Object> dataMap = new Map<String, Object>{
            B2BConstants.ORDER_SUMMARY_NUMBER => 'TestOrderNumber' // Use the test order number you've created
        };

        Map<String,Object> addressResult = B2BOrderConfirmationController.getAddressInformation(dataMap);
        B2BOrderConfirmationController.getAddressInformation(null);
        System.assertNotEquals(0, addressResult.size(), 'Order item summaries should not be empty.');
    }

}