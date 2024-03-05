global with sharing class Event_Calendar_RemoteController {

    @RemoteAction
    global static Event_Calendar_ResponseWrappers getAttachments(String parentId) {
        return Event_Calendar_APILogicWrapper.getAttachments(parentId);
    }

    @RemoteAction
    global static Event_Calendar_ResponseWrappers getCampaignDetail(String campaignId) {
        return Event_Calendar_APILogicWrapper.getCampaignDetail(campaignId);
    }

    @RemoteAction
    global static Event_Calendar_ResponseWrappers getCampaigns(Integer month, Integer year) {
        return Event_Calendar_APILogicWrapper.getCampaigns(month, year);
    }

    @RemoteAction
    global static Event_Calendar_ResponseWrappers getCampaignsSearch(String searchParameter) {
        return Event_Calendar_APILogicWrapper.getCampaignsSearch(searchParameter);
    }
}