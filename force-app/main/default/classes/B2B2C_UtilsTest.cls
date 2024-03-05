@isTest
private class B2B2C_UtilsTest {

    @isTest static void test_resolveCommunityIdToWebstoreId() {
        // Setting up test data
        WebStore ws = new WebStore(Name='Test WebStore');
        insert ws;

        Network n =[SELECT Id, Name, Status FROM Network WHERE Status = 'Live' LIMIT 1];
        
        WebStoreNetwork wsn = new WebStoreNetwork(NetworkId=n.Id, WebStoreId=ws.Id);
        insert wsn;

        // Test method
       
        String returnedWebStoreId = B2B2C_Utils.resolveCommunityIdToWebstoreId(n.Id);
        System.assertEquals(ws.Id, returnedWebStoreId);
       
    }

    @isTest static void test_getUserAccountId() {
        System.runAs(new User(Id=UserInfo.getUserId())) {
            String accountId = B2B2C_Utils.getUserAccountID();
            System.assertNotEquals('null', accountId);
        }
    }

    @isTest static void test_isNullOrEmpty() {
        System.assertEquals(true, B2B2C_Utils.isNullOrEmpty(''));
        System.assertEquals(true, B2B2C_Utils.isNullOrEmpty(null));
        System.assertEquals(true, B2B2C_Utils.isNullOrEmpty(new List<String>()));
        //System.assertEquals(true, B2B2C_Utils.isNullOrEmpty(new Set<String>()));
        System.assertEquals(true, B2B2C_Utils.isNullOrEmpty(new Map<String, String>()));

        System.assertEquals(false, B2B2C_Utils.isNullOrEmpty('Hello'));
        System.assertEquals(false, B2B2C_Utils.isNullOrEmpty(new List<String>{'Test'}));
        System.assertEquals(false, B2B2C_Utils.isNullOrEmpty(new Set<String>{'Test'}));
        System.assertEquals(false, B2B2C_Utils.isNullOrEmpty(new Map<String, String>{'Key' => 'Value'}));
    }

    @isTest static void test_isNotNullOrEmpty() {
        System.assertEquals(false, B2B2C_Utils.isNotNullOrEmpty(''));
        System.assertEquals(false, B2B2C_Utils.isNotNullOrEmpty(null));
        System.assertEquals(false, B2B2C_Utils.isNotNullOrEmpty(new List<String>()));
        //System.assertEquals(false, B2B2C_Utils.isNotNullOrEmpty(new Set<String>()));
        System.assertEquals(false, B2B2C_Utils.isNotNullOrEmpty(new Map<String, String>()));

        System.assertEquals(true, B2B2C_Utils.isNotNullOrEmpty('Hello'));
        System.assertEquals(true, B2B2C_Utils.isNotNullOrEmpty(new List<String>{'Test'}));
        System.assertEquals(true, B2B2C_Utils.isNotNullOrEmpty(new Set<String>{'Test'}));
        System.assertEquals(true, B2B2C_Utils.isNotNullOrEmpty(new Map<String, String>{'Key' => 'Value'}));
    }

    // Add other test methods as needed
}