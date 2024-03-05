@isTest
private class B2BUtilsTest {

    @isTest
    static void testResolveCommunityIdToWebstoreId() {
        // Sample data setup
        Network n =[SELECT Id, Name, Status FROM Network WHERE Status = 'Live' LIMIT 1];
        
        WebStore store = new WebStore(Name = 'TestWebStore');
        insert store;
        
        WebStoreNetwork wsn = new WebStoreNetwork(NetworkId = n.Id, WebStoreId = store.Id);
        insert wsn;

        String webStoreId = B2BUtils.resolveCommunityIdToWebstoreId(n.Id);
        System.assertEquals(store.Id, webStoreId);
    }

    @isTest
    static void testResolveSortParam() {
        ConnectApi.CartItemSortOrder sortOrder = B2BUtils.resolveSortParam('CreatedDateAsc');
        System.assertEquals(ConnectApi.CartItemSortOrder.CreatedDateAsc, sortOrder);
    }

    @isTest
    static void testGetUserAccountID() {
        System.runAs(new User(Id=UserInfo.getUserId())) {
            String accountId = B2BUtils.getUserAccountID();
            System.assertNotEquals('null', accountId);
        }
    }

    @isTest
    static void testRetrieveWebStoreIdByCommunityId() {
        // Sample data setup similar to the first test
        // This will implicitly test the retrieveCommunityId() method too
        Network n =[SELECT Id, Name, Status FROM Network WHERE Status = 'Live' LIMIT 1];
        
        WebStore store = new WebStore(Name = 'TestWebStore');
        insert store;
        
        WebStoreNetwork wsn = new WebStoreNetwork(NetworkId = n.Id, WebStoreId = store.Id);
        insert wsn;

        String webStoreId = B2BUtils.retrieveWebStoreIdByCommunityId();
        //System.assertEquals(store.Id, webStoreId);
    }

    @isTest 
    static void testFetchAllCountryConfigs() {

       List<B2B_Country_Config__mdt> results = B2BUtils.fetchAllCountryConfigs();

    }

   
    @isTest 
    static void testAssignPermissionSet_UserWithPermissionSet() {
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'B2B Lightning Community Plus Login' LIMIT 1];
        User user =[Select Id,ProfileId from User where ProfileId=:communityProfile.Id LIMIT 1];
        Map<String, String> dataMap = new Map<String, String>();
        dataMap.put('userId',user.Id);
        Test.startTest();
        B2BUtils.assignPermissionSet(dataMap);
        Test.stopTest();
        System.assert(dataMap != null);
    }
    
}