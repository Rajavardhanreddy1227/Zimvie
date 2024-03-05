@isTest
public class AdvanceShippingNotice_Test {
    @isTest
    static void advanceMethod(){
        Test.startTest();
        AdvanceShippingNotice advance = new AdvanceShippingNotice();
        advance.FulfillmentOrderItemNumber ='Test';
        advance.FulfillmentOrderNumber ='Testing';
        advance.QuantityCancelled = 90.00;
        advance.QuantityFulfilled = 80.00;
        Test.stopTest();

    }
}