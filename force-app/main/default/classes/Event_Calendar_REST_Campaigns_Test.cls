@isTest
private class Event_Calendar_REST_Campaigns_Test {

    @testSetup static void setupData() {
        List<Campaign> camps = new List<Campaign>();
        for (Integer i = 0; i < 25; i++) {
            camps.add(Event_Calendar_TestHelper.createCampaign());
        }
        insert camps;
    }

    @isTest static void doGetCampaigns() {
        Integer month = Date.today().month();
        Integer year = Date.today().year();
        String httpMethod = 'GET';
        String requestURI = '/campaigns/month/' + month + '/year/' + year;
        Event_Calendar_TestHelper.setupRestSettings(httpMethod, requestURI);
        Event_Calendar_ResponseWrappers response = Event_Calendar_REST_Campaigns.doGet();
        System.assertNotEquals(null, response.dataList);
        System.assertEquals(25, response.dataList.size());
        System.assertEquals(true, response.success);
    }

    @isTest static void doGetCampaignsError() {
        Integer month = Date.today().month();
        String httpMethod = 'GET';
        String requestURI = '/campaigns/month/' + month + '/year/';
        Event_Calendar_TestHelper.setupRestSettings(httpMethod, requestURI);
        Event_Calendar_ResponseWrappers response = Event_Calendar_REST_Campaigns.doGet();
        System.assertEquals(false, response.success);
        System.assertEquals(Event_Calendar_APILogicWrapper.ERROR_MSG, response.message);
    }
}