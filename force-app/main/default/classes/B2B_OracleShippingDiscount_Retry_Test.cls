@isTest
public class B2B_OracleShippingDiscount_Retry_Test {

    @isTest
    static void B2B_OracleShippingMethod(){
        Account acc = new Account();
        acc.Name = 'Test Name';
        acc.Type = 'Customer';
        acc.Customer_Type__c = 'Pharmacy';
        acc.Account_eMail__c = 'lauren119@yopmail.com';
        acc.Email__c = 'neeta.galande@rafter.one';
        acc.ShippingCountry = 'United States';
        acc.ShippingState = 'Alabama';
        acc.ShippingPostalCode = '12345';
        insert acc;
         WebStore webStore = new WebStore(
            Name = 'Test'
        );
        insert webStore;
        WebCart testCart = new WebCart(Name = 'testCart', WebStoreId = webStore.Id, AccountId = acc.id);
        insert testCart;
        String body = '<sampleXml></sampleXml>';
        String endpointUrl = 'https://example.com/api';
        String cartId = testCart.Id ;
        B2B_OracleShippingDiscount_Retry callout = new B2B_OracleShippingDiscount_Retry(body,endpointUrl,cartId);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseOracle());
        Test.startTest();
        JobResult resulting = callout.startJob();
        Test.stopTest();
    }
}