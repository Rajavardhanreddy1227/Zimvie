@IsTest(SeeAllData=true)
public class B2BCancelOrderController_Test {
   public static Account acc;
   public static Contract testContract;
   public static Order order;
   public static Order updatedOrder;
   public static OrderSummary updatedOrderSummary;
   private static void loadData(Boolean createContract) {
       acc = new Account(Name = 'Test');
       insert acc;
       testContract = new Contract(AccountId = acc.Id, StartDate = Date.today(), ContractTerm = 12);
       insert testContract;
       Id pbId = Test.getStandardPricebookId();
       // Create an Order
       order = new Order(
           AccountId = acc.Id,
           Pricebook2Id = pbId,
           EffectiveDate = Date.today(),
           OrderedDate = Date.today(),
           Status = 'Draft'
       );
       insert order;
       OrderDeliveryMethod m = new OrderDeliveryMethod();
       m.Name = 'Test';
       insert m;
       // Create an Order Delivery Group
       OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup(
           Description = 'cartDeliveryGroup.Description',
           DesiredDeliveryDate = Date.today(),
           DeliverToName = 'cartDeliveryGroup.DeliverToName',
           DeliveryInstructions = 'cartDeliveryGroup.ShippingInstructions',
           OrderDeliveryMethodId = m.Id,
           OrderId = order.Id
       );
       insert orderDeliveryGroup;
       // Create a Product (Product2) if not already created
       Product2 prod = new Product2(Name = 'Test Product');
       insert prod;
       // Create a PricebookEntry for the Product
       PricebookEntry pbe = new PricebookEntry(
           Pricebook2Id = pbId,
           Product2Id = prod.Id,
           UnitPrice = 1,
           IsActive = true,
           UseStandardPrice = false
       );
       insert pbe;

       // Create an OrderItem associated with the Order and Order Delivery Group
       OrderItem orderItem = new OrderItem(
           Product2Id = prod.Id,
           Quantity = 1,
           ListPrice = 1,
           UnitPrice = 1,
           OrderId = order.Id,
           PricebookEntryId = pbe.Id,
           OrderDeliveryGroupId = orderDeliveryGroup.Id,
           TotalLineAmount = 47
       );
       insert orderItem;

       // Update the Order
       order.Status = 'Activated';
       update order;

       ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
       osir.orderId = order.Id; // replace this recordId with an appropriate value.
       osir.orderLifeCycleType = 'UNMANAGED';
       ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);

       // Call the method to be tested
       B2BCancelOrderController.cancelOrder(osor.OrderSummaryId, order.Id, acc.Id);

       // Retrieve the updated records
       updatedOrder = [SELECT Id, ContractId, Status FROM Order WHERE Id = :order.Id];
       updatedOrderSummary = [SELECT Id, Status FROM OrderSummary WHERE Id = :osor.OrderSummaryId];
   }

   @isTest
   public static void testCancelOrder() {
       loadData(false);

       // Verify the updated values
       System.assertEquals(testContract.Id, updatedOrder.ContractId);
       System.assertEquals('Draft', updatedOrder.Status);
       System.assertEquals('Cancelled', updatedOrderSummary.Status);
   }

   @IsTest(SeeAllData=true)
   public static void testCancelOrder2() {
       loadData(true);

       // Verify the updated values
       System.assertEquals(testContract.Id, updatedOrder.ContractId);
       System.assertEquals('Draft', updatedOrder.Status);
       System.assertEquals('Cancelled', updatedOrderSummary.Status);
   }
}