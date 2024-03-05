@RestResource(urlMapping = '/campaigns/month/*/year/*')
global with sharing class Event_Calendar_REST_Campaigns {

    @HttpGet
    global static Event_Calendar_ResponseWrappers doGet() {
        List<String> reqParam =  RestContext.request.requestURI.split('/');
        if (reqParam.size() < 6) {
            return new Event_Calendar_ResponseWrappers(false, Event_Calendar_APILogicWrapper.ERROR_MSG);
        }

        Integer month = Integer.valueof(reqParam.get(3));
        Integer year = Integer.valueof(reqParam.get(5));
        return Event_Calendar_APILogicWrapper.getCampaigns(month, year);
    }
}