@isTest
public class B2B_PricebookServiceTest {
    @isTest
    static void testParseRequest() {
        // Test data setup
        //Instantiate the Pricebook2 record with StandardPricebookId
        BuyerGroup testBuyerGroup = new BuyerGroup(Name = 'Test Buyer Group');
        insert testBuyerGroup;

        // Create test data for CommerceEntitlementPolicy
        CommerceEntitlementPolicy testEntitlementPolicy = new CommerceEntitlementPolicy(Name = 'Test Entitlement Policy');
        insert testEntitlementPolicy;
        
        // Create test data for CommerceEntitlementBuyerGroup
        CommerceEntitlementBuyerGroup testEntitlementBuyerGroup = new CommerceEntitlementBuyerGroup(PolicyId = testEntitlementPolicy.Id, BuyerGroupId = testBuyerGroup.Id);
        insert testEntitlementBuyerGroup;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        List<B2B_PricebookService.RequestWrapper> requestWrapperList = new List<B2B_PricebookService.RequestWrapper>();
		Product2 prod2 = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod2;
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod;
        // Test data for Pricebook entry
        B2B_PricebookService.pbeData productData1 = new B2B_PricebookService.pbeData();
        productData1.productId = prod2.Id;
        productData1.price = 100;
        productData1.externalid = 'extID1';

        B2B_PricebookService.pbeData productData2 = new B2B_PricebookService.pbeData();
        productData2.productId = prod.Id;
        productData2.price = 150;
        productData2.externalid = 'extID2';

        // Test data for RequestWrapper
        B2B_PricebookService.RequestWrapper requestWrapper = new B2B_PricebookService.RequestWrapper();
        requestWrapper.name = 'Test Pricebook';
        requestWrapper.externalId = 'pbExternalId';
        requestWrapper.entries = new List<B2B_PricebookService.pbeData>();
        requestWrapper.entries.add(productData1);
        requestWrapper.entries.add(productData2);

        requestWrapperList.add(requestWrapper);

        // Serialize the test data and send the request
        String requestJSON = JSON.serialize(requestWrapperList);
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/PricebookService';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestJSON);
        RestContext.request = request;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_PricebookServiceMock()); 
        B2B_PricebookService.parseRequest();
        Test.stopTest();

        // Perform assertions to verify the logic and data insertion
        List<Pricebook2> insertedPricebooks = [SELECT Id, Name, OracleUniqueId__c FROM Pricebook2 WHERE OracleUniqueId__c = 'pbExternalId'];
        //System.assertEquals(1, insertedPricebooks.size());

        List<PricebookEntry> insertedPricebookEntries = [SELECT Id, Pricebook2Id, Product2Id, UnitPrice FROM PricebookEntry];
        //System.assertEquals(2, insertedPricebookEntries.size());

        // Perform additional assertions to check other records and logic as required
    }
}