@isTest
private class B2B_GetCommunityDetails_Test {
    @isTest
    static void testGetCommunityURL() {
        Test.startTest();
        List<String> result = B2B_GetCommunityDetails.getCommunityURL();
        Test.stopTest();
        System.assertEquals(1, result.size());
    }
}