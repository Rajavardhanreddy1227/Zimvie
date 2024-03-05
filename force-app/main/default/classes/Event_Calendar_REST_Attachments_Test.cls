@isTest
private class Event_Calendar_REST_Attachments_Test {

    @testSetup static void setupData() {
        Campaign camp = Event_Calendar_TestHelper.createCampaign();
        insert camp;
        List<Attachment> attachs = new List<Attachment>();
        for (Integer i = 0; i < 25; i++) {
            attachs.add(Event_Calendar_TestHelper.createAttachment(camp.Id, i));
        }
        insert attachs;
    }

    @isTest static void doGetAttachments() {
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String httpMethod = 'GET';
        String requestURI = '/attachments/parentid/' + camp.Id;
        Event_Calendar_TestHelper.setupRestSettings(httpMethod, requestURI);
        Event_Calendar_ResponseWrappers response = Event_Calendar_REST_Attachments.doGet();
        System.assertEquals(true, response.success);
        System.assertNotEquals(null, response.dataList);
        System.assertEquals(25, response.dataList.size());
    }

    @isTest static void doGetAttachmentsError() {
        String httpMethod = 'GET';
        String requestURI = '/attachments/parentid/';
        Event_Calendar_TestHelper.setupRestSettings(httpMethod, requestURI);
        Event_Calendar_ResponseWrappers response = Event_Calendar_REST_Attachments.doGet();
        System.assertEquals(Event_Calendar_APILogicWrapper.ERROR_MSG, response.message);
        System.assertEquals(false, response.success);
    }
}