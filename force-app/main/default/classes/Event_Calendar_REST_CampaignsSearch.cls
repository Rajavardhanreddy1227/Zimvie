@RestResource(urlMapping = '/campaigns/search/*')
global with sharing class Event_Calendar_REST_CampaignsSearch {

    @HttpGet
    global static Event_Calendar_ResponseWrappers doGet() {
        List<String> parameters = RestContext.request.requestURI.split('/');
        if (parameters.size() < 4) {
            return new Event_Calendar_ResponseWrappers(false, Event_Calendar_APILogicWrapper.ERROR_MSG);
        }
        String parameter = parameters.get(3);
        return Event_Calendar_APILogicWrapper.getCampaignsSearch(parameter);
    }
}