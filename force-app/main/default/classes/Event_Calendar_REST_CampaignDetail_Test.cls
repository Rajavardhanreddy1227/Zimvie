@isTest
private class Event_Calendar_REST_CampaignDetail_Test {

    @testSetup static void setupData() {
        List<Campaign> camps = new List<Campaign>();
        for (Integer i = 0; i < 25; i++) {
            camps.add(Event_Calendar_TestHelper.createCampaign());
        }
        insert camps;
    }

    @isTest static void doGetCampaignDetail() {
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String httpMethod = 'GET';
        String requestURI = '/campaigns/id/' + camp.Id;
        Event_Calendar_TestHelper.setupRestSettings(httpMethod, requestURI);
        Event_Calendar_ResponseWrappers response = Event_Calendar_REST_CampaignDetail.doGet();
        System.assertEquals(true, response.success);
        System.assertNotEquals(null, response.data);
    }

    @isTest static void doGetCampaignDetailError() {
        String httpMethod = 'GET';
        String requestURI = '/campaigns/id';
        Event_Calendar_TestHelper.setupRestSettings(httpMethod, requestURI);
        Event_Calendar_ResponseWrappers response = Event_Calendar_REST_CampaignDetail.doGet();
        System.assertEquals(false, response.success);
        System.assertEquals(Event_Calendar_APILogicWrapper.ERROR_MSG, response.message);
    }
}