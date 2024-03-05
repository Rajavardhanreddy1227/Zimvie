@isTest
public class B2B_AccountEnablementBatchTest {

    @isTest
    static void testBatch() {
        BuyerGroup objBG = new BuyerGroup(Name='ZimVie Buyer Group');
        insert objBG;
        
        // Create test Pricebook2 records
        List<Pricebook2> testPricebooks = new List<Pricebook2>();
        for (Integer i = 0; i < 5; i++) {
            Pricebook2 pb = new Pricebook2(
                Name = 'Test Pricebook ' + i,
                Source_External_id__c = 'ExternalID-' + i
            );
            testPricebooks.add(pb);
        }
        insert testPricebooks;

        // Create test BuyerGroupPricebook records
        List<BuyerGroupPricebook> testBuyerGroupPricebooks = new List<BuyerGroupPricebook>();
        for (Pricebook2 pb : testPricebooks) {
            BuyerGroupPricebook bgp = new BuyerGroupPricebook(
                BuyerGroupId = objBG.Id,
                PriceBook2Id = pb.Id
            );
            testBuyerGroupPricebooks.add(bgp);
        }
        insert testBuyerGroupPricebooks;
		Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Ecommerce Account').getRecordTypeId();
        // Create test accounts
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account acc = new Account(
                Name = 'Test Account ' + i,
                Oracle_Pricelist_External_ID__c = 'ExternalID-' + i,
                RecordTypeId = devRecordTypeId
            );
            testAccounts.add(acc);
        }
        insert testAccounts;
        Set<Id> setAccId = new Set<Id>();
        for(Account objAcc : testAccounts){
            setAccId.add(objAcc.Id);
        }
        Test.startTest();
        // Start the batch process
        B2B_AccountEnablementBatch batch = new B2B_AccountEnablementBatch(setAccId);
        Id batchInstanceId = Database.executeBatch(batch, 200);
        Test.stopTest();

        // Verify that the BuyerGroupMembers were created
        List<BuyerGroupMember> buyerGroupMembers = [
            SELECT Id, BuyerId, BuyerGroupId
            FROM BuyerGroupMember
            WHERE BuyerId IN :testAccounts AND BuyerGroupId =:objBG.Id
        ];
        //System.assertEquals(testAccounts.size(), buyerGroupMembers.size());
    }
}