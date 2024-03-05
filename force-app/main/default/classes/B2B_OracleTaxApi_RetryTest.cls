@isTest
public class B2B_OracleTaxApi_RetryTest {
    @testSetup
    static void makeData(){
        Account account = new Account(Name='TestAccount');
        insert account;
        WebStore webStore = new WebStore(Name='TestWebStore');
        insert webStore;
        Product2 pro = new Product2(
            Name = 'Sort Material-450',
            IsActive = true,
            StockKeepingUnit = 'Sort',
            ProductCode ='PC-110'
        );
        insert pro;
        ContactPointAddress contactAddress = new ContactPointAddress( Name='Billing');
        insert contactAddress;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id,Selected_Contact_Point_Address__c = contactAddress.Id);
        insert cart;
        OrderDeliveryMethod ordDeliveryMethod = new OrderDeliveryMethod(
            Name = 'OrderDelivery',
            ProductId = pro.Id,
            IsActive = true
        );
        insert ordDeliveryMethod;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
            CartId = cart.Id,
            DeliveryMethodId = ordDeliveryMethod.Id,
            Name = 'OrderDeliveryGroup',
            DeliverToName = 'OrderDeliver'
            
        );
        insert cartDeliveryGroup;
        CartItem cartItem = new CartItem(
            CartId=cart.Id, 
            Sku='SKU_Test1', 
            Quantity=3.0, 
            Type='Product',
            CurrencyIsoCode = 'USD',
            ListPrice = 10.89,
            TotalPrice = 30,
            Product2Id= pro.Id,
            
            Name='originalCartItems', 
            CartDeliveryGroupId=cartDeliveryGroup.Id
        );
        insert cartItem;
    }
    @isTest
    static void testConstructor() {
        WebCart cart = [Select id,name from WebCart where Name='Cart'];
        CartItem carItem =[Select id,Sku, Type,name,TotalPrice,Product2Id,Product2.ProductCode,CartId from CartItem where Name='originalCartItems' AND CartId =:cart.id];
        String body = '<sampleXml></sampleXml>';
        String endpointUrl = 'https://example.com/api';
        Map<String, Object> entryVsCartItemMap = new Map<String, Object>();
        entryVsCartItemMap.put('1',carItem);
        String inputCartId = cart.Id;
        B2B_OracleTaxApi_Retry retryInstance = new B2B_OracleTaxApi_Retry(body, endpointUrl, entryVsCartItemMap, inputCartId);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseTax());
        Test.startTest();
        JobResult result = retryInstance.startJob();
        Test.stopTest();
    }
    @isTest
    static void externalClassMethod(){
        B2B_OracleTaxApi_Retry.TaxDataFromExternalService retData = new B2B_OracleTaxApi_Retry.TaxDataFromExternalService();
        retData.getRate();
        retData.getAmount();
        retData.getTaxName();
    }
    
    
    
    
}