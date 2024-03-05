@isTest
private class Event_Calendar_Test_Suite {
	 @testSetup static void setupData() {
        Campaign camp = Event_Calendar_TestHelper.createCampaign();
        insert camp;
        List<Attachment> attachs = new List<Attachment>();
        for (Integer i = 0; i < 25; i++) {
            attachs.add(Event_Calendar_TestHelper.createAttachment(camp.Id, i));
        }
        List<Campaign> camps = new List<Campaign>();
        for (Integer i = 0; i < 25; i++) {
            camps.add(Event_Calendar_TestHelper.createCampaign());
        }
        List<Campaign> camps1 = new List<Campaign>();
        for (Integer i = 0; i < 25; i++) {
            camps1.add(Event_Calendar_TestHelper.createCampaign(String.valueOf(i)));
        }
        insert camps;
        insert camps1;
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
    /* @testSetup static void setupData1() {
        List<Campaign> camps = new List<Campaign>();
        for (Integer i = 0; i < 25; i++) {
            camps.add(Event_Calendar_TestHelper.createCampaign());
        }
        insert camps;
    }*/

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
	 @isTest static void doGetCampaigns() {
        Integer month = Date.today().month();
        Integer year = Date.today().year();
        String httpMethod = 'GET';
        String requestURI = '/campaigns/month/' + month + '/year/' + year;
        Event_Calendar_TestHelper.setupRestSettings(httpMethod, requestURI);
        Event_Calendar_ResponseWrappers response = Event_Calendar_REST_Campaigns.doGet();
        System.assertNotEquals(null, response.dataList);
       // System.assertEquals(25, response.dataList.size());
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
      //  System.assertEquals(25, response.dataList.size());
        System.assertEquals(true, response.success);
    }

    @isTest static void getCampaignsSearch() {
        setupCampaignsCustomName();
        String searchParameter = '12';
        Event_Calendar_ResponseWrappers result = Event_Calendar_RemoteController.getCampaignsSearch(searchParameter);
        System.assertNotEquals(null, result.dataList);
      //  System.assertEquals(1, result.dataList.size());
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