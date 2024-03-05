public with sharing class Event_Calendar_TestHelper {

    public static  Campaign createCampaign(String name) {
        Campaign camp = new Campaign();
        camp.Name = name;
        camp.StartDate = Date.today();
        camp.EndDate = Date.today().addDays(14);
        camp.Segment__c = 'test';
        camp.Event_Website__c = 'test.test.com';
        camp.IsActive = true;
        camp.City__c = 'test city';
        camp.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Cvent Campaign').getRecordTypeId();
        return camp;
    }

    public static Campaign createCampaign() {
        Campaign camp = new Campaign();
        camp.Name = 'test campaign';
        camp.StartDate = Date.today();
        camp.EndDate = Date.today().addDays(14);
        camp.Segment__c = 'test';
        camp.Event_Website__c = 'test.test.com';
        camp.IsActive = true;
        camp.City__c = 'test city';
        camp.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Cvent Campaign').getRecordTypeId();
        return camp;
    }

    public static void setupRestSettings(String httpMethod, String requestURI) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = requestURI;
        req.httpMethod = httpMethod;
        RestContext.request = req;
        RestContext.response = res;
    }

    public static Attachment createAttachment(Id parentId, Integer num) {
        Attachment attach = new Attachment();
        attach.Body = Blob.toPdf('test');
        attach.Name = 'test attach' + String.valueOf(num);
        attach.ParentId = parentId;
        return attach;
    }
}