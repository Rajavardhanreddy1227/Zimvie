@isTest
private class CommerceUtilsTest {

    @isTest
    static void testResolveCommunityIdToWebstoreId() {
        // Create a test WebStoreNetwork record
       // WebStoreNetwork__c testWebStore = new WebStoreNetwork__c(NetworkId = 'TestCommunityId', WebStoreId = 'TestWebStoreId');
      //  insert testWebStore;

        // Call the utility method
        String resolvedWebStoreId = CommerceUtils.resolveCommunityIdToWebstoreId('TestCommunityId');
        
        // Verify the result
        System.assertEquals('TestWebStoreId', resolvedWebStoreId);
    }

    @isTest
    static void testResolveCommunityIdToWebstoreId_CacheHit() {
        // Prepare the cache
        CommerceUtils.communityIdToWebStoreIdCache.put('TestCommunityId', 'TestCachedWebStoreId');
        
        // Call the utility method
        String resolvedWebStoreId = CommerceUtils.resolveCommunityIdToWebstoreId('TestCommunityId');
        
        // Verify the result
        System.assertEquals('TestCachedWebStoreId', resolvedWebStoreId);
    }
}