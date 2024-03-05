@isTest
public class PricebookTriggerHandlerTest {
    @isTest
    static void testHandlePricebookInsert() {
        // Create test data for Webstore
        Webstore testWebstore = new Webstore(Name = 'Zimvie');
        insert testWebstore;

        // Create test data for Pricebook2
        Pricebook2 testPricebook = new Pricebook2(Name = 'Test Pricebook', Source_External_id__c = 'uniqueId');
        insert testPricebook;

        Test.startTest();
        // Invoke the trigger handler method
        List<Pricebook2> pricebooksToInsert = new List<Pricebook2>();
        pricebooksToInsert.add(testPricebook);
        PricebookTriggerHandler.handlePricebookInsert(pricebooksToInsert);
        Test.stopTest();

        // Verify BuyerGroup, CommerceEntitlementPolicy, and BuyerGroupPricebook records were inserted
        List<BuyerGroup> buyerGroups = [SELECT Id, Name FROM BuyerGroup];
        System.assertEquals(1, buyerGroups.size());

        List<CommerceEntitlementPolicy> entitlementPolicies = [SELECT Id, Name FROM CommerceEntitlementPolicy];
        System.assertEquals(1, entitlementPolicies.size());

        List<BuyerGroupPricebook> buyerGroupPricebooks = [SELECT Id, BuyerGroupId, Pricebook2Id FROM BuyerGroupPricebook];
        System.assertEquals(1, buyerGroupPricebooks.size());

        // Verify WebStoreBuyerGroup record was inserted
        List<WebStoreBuyerGroup> webStoreBuyerGroups = [SELECT Id, BuyerGroupId, WebStoreId FROM WebStoreBuyerGroup];
        System.assertEquals(1, webStoreBuyerGroups.size());
    }

    @isTest
    static void testHandlePricebookUpdate() {
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        // Create test data for Webstore
        Webstore testWebstore = new Webstore(Name = 'Zimvie');
        insert testWebstore;

        // Create test data for Pricebook2
        Pricebook2 oldPricebook = new Pricebook2(Name = 'Old Pricebook', Source_External_id__c = 'uniqueId1');
        insert oldPricebook;

        Pricebook2 updatedPricebook = new Pricebook2(Id = oldPricebook.Id, Name = 'Updated Pricebook', Source_External_id__c = 'uniqueId1');
        update updatedPricebook;

        // Create test data for BuyerGroup
        BuyerGroup testBuyerGroup = new BuyerGroup(Name = 'Test Buyer Group');
        insert testBuyerGroup;

        // Create test data for CommerceEntitlementPolicy
        CommerceEntitlementPolicy testEntitlementPolicy = new CommerceEntitlementPolicy(Name = 'Test Entitlement Policy');
        insert testEntitlementPolicy;

        // Create test data for BuyerGroupPricebook
        BuyerGroupPricebook testBuyerGroupPricebook = new BuyerGroupPricebook(BuyerGroupId = testBuyerGroup.Id, Pricebook2Id = oldPricebook.Id);
        insert testBuyerGroupPricebook;

        // Create test data for CommerceEntitlementBuyerGroup
        CommerceEntitlementBuyerGroup testEntitlementBuyerGroup = new CommerceEntitlementBuyerGroup(PolicyId = testEntitlementPolicy.Id, BuyerGroupId = testBuyerGroup.Id);
        insert testEntitlementBuyerGroup;

        Test.startTest();
        // Invoke the trigger handler method
        List<Pricebook2> updatedPricebooks = new List<Pricebook2>{updatedPricebook};
        Map<Id, Pricebook2> oldPricebooks = new Map<Id, Pricebook2>{oldPricebook.Id => oldPricebook};
        PricebookTriggerHandler.handlePricebookUpdate(updatedPricebooks, oldPricebooks);
        Test.stopTest();

        // Verify BuyerGroup and CommerceEntitlementPolicy records were updated
        List<BuyerGroup> buyerGroups = [SELECT Id, Name FROM BuyerGroup WHERE Id = :testBuyerGroup.Id];
        System.assertEquals(1, buyerGroups.size());
        System.assertEquals('Updated Pricebook Buyer Group', buyerGroups[0].Name);

        List<CommerceEntitlementPolicy> entitlementPolicies = [SELECT Id, Name FROM CommerceEntitlementPolicy WHERE Id = :testEntitlementPolicy.Id];
        System.assertEquals(1, entitlementPolicies.size());
        System.assertEquals('Updated Pricebook Entitlement Policy', entitlementPolicies[0].Name);
    }
}