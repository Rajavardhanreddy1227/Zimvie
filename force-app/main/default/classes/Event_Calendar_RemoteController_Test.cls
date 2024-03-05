@isTest
private class Event_Calendar_RemoteController_Test {

    @isTest static void getAttachments() {
        setupAttachments();
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        Event_Calendar_ResponseWrappers response = Event_Calendar_RemoteController.getAttachments(camp.Id);
        System.assertEquals(true, response.success);
        System.assertNotEquals(null, response.dataList);
        System.assertEquals(25, response.dataList.size());
    }


    @isTest static void getCampaignDetail() {
        setupCampaigns();
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        Event_Calendar_ResponseWrappers response = Event_Calendar_RemoteController.getCampaignDetail(camp.Id);
        System.assertEquals(true, response.success);
        System.assertNotEquals(null, response.data);
    }

    @isTest static void getCampaigns() {
        setupCampaigns();
        Integer month = Date.today().month();
        Integer year = Date.today().year();
        Event_Calendar_ResponseWrappers response = Event_Calendar_RemoteController.getCampaigns(month, year);
        System.assertNotEquals(null, response.dataList);
        System.assertEquals(25, response.dataList.size());
        System.assertEquals(true, response.success);
    }

    @isTest static void getCampaignsSearch() {
        setupCampaignsCustomName();
        String searchParameter = '12';
        Event_Calendar_ResponseWrappers result = Event_Calendar_RemoteController.getCampaignsSearch(searchParameter);
        System.assertNotEquals(null, result.dataList);
        System.assertEquals(1, result.dataList.size());
        System.assertEquals(true, result.success);
    }

    private static void setupAttachments() {
        Campaign camp = Event_Calendar_TestHelper.createCampaign();
        insert camp;
        List<Attachment> attachs = new List<Attachment>();
        for (Integer i = 0; i < 25; i++) {
            attachs.add(Event_Calendar_TestHelper.createAttachment(camp.Id, i));
        }
        insert attachs;
    }

    private static void setupCampaigns() {
        List<Campaign> camps = new List<Campaign>();
        for (Integer i = 0; i < 25; i++) {
            camps.add(Event_Calendar_TestHelper.createCampaign());
        }
        insert camps;
    }

    private static void setupCampaignsCustomName() {
        List<Campaign> camps = new List<Campaign>();
        for (Integer i = 0; i < 25; i++) {
            camps.add(Event_Calendar_TestHelper.createCampaign(String.valueOf(i)));
        }
        insert camps;
    }
}