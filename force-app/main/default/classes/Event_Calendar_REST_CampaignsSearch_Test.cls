@isTest
private class Event_Calendar_REST_CampaignsSearch_Test {

    @testSetup static void setupData() {
        List<Campaign> camps = new List<Campaign>();
        for (Integer i = 0; i < 25; i++) {
            camps.add(Event_Calendar_TestHelper.createCampaign(String.valueOf(i)));
        }
        insert camps;
    }

    @isTest static void doGetCampaignsSearchWithParam() {
        String httpMethod = 'GET';
        String searchName = '12';
        String requestURI = '/campaigns/search/' + searchName;
        Event_Calendar_TestHelper.setupRestSettings(httpMethod, requestURI);
        Event_Calendar_ResponseWrappers result = Event_Calendar_REST_CampaignsSearch.doGet();
        System.assertNotEquals(null, result.dataList);
        System.assertEquals(1, result.dataList.size());
        System.assertEquals(true, result.success);
    }

    @isTest static void doGetCampaignsSearchWithOutParam() {
        String httpMethod = 'GET';
        String requestURI = '/campaigns/search/';
        Event_Calendar_TestHelper.setupRestSettings(httpMethod, requestURI);
        Event_Calendar_ResponseWrappers result = Event_Calendar_REST_CampaignsSearch.doGet();
        System.assertEquals(null, result.dataList);
        System.assertEquals(null, result.data);
        System.assertEquals(false, result.success);
    }

}