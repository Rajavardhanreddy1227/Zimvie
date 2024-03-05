public with sharing class Event_Calendar_APILogicWrapper {   

    public static String ERROR_MSG = 'Please input a search string.';
    private static String CORRECT_MSG = 'Correct request';

    public static Event_Calendar_ResponseWrappers getAttachments(String parentId) {
        List<Event_Calendar_ResponseWrappers.AttachmentWrapper> results = new List<Event_Calendar_ResponseWrappers.AttachmentWrapper>();
        String query = 'SELECT Id, Name FROM Attachment WHERE ParentId = :parentId';
        try {
            for (Attachment attach : Database.query(query)) {
                results.add(new Event_Calendar_ResponseWrappers.AttachmentWrapper(attach.Name, attach.Id));
            }
            return new Event_Calendar_ResponseWrappers(true, CORRECT_MSG, results);
        } catch (Exception e) {
            return new Event_Calendar_ResponseWrappers(false, e.getMessage());
        }
    }

    public static Event_Calendar_ResponseWrappers getCampaignDetail(String campaignId) {
        String query = 'SELECT Id, Name, StartDate, Event_Website__c, EndDate, Segment__c, City__c, State__c, Country__c '
                       + 'FROM Campaign WHERE Id =: campaignId LIMIT 1';
        try {
            Campaign camp = Database.query(query);
            return new Event_Calendar_ResponseWrappers(true, CORRECT_MSG,
                    new Event_Calendar_ResponseWrappers.CampaignDetailWrapper(camp));
        } catch (Exception e) {
            return new Event_Calendar_ResponseWrappers(false, e.getMessage());
        }
    }

    public static Event_Calendar_ResponseWrappers getCampaigns(Integer month, Integer year) {
        List<Event_Calendar_ResponseWrappers.CampaignWrapper> results = new List<Event_Calendar_ResponseWrappers.CampaignWrapper>();
        Integer daysInMonth = Date.daysInMonth(year, month);
        Date startOfMonth = Date.newInstance(year, month, 2).toStartOfMonth();
        Date endOfMonth = startOfMonth.addDays(daysInMonth);
        String query = 'SELECT '
                       + 'Id, Name, StartDate, EndDate, Segment__c, Event_Website__c, Status, Type, Country__c, State__c, City__c '
                       + 'FROM Campaign '
                       + 'WHERE IsActive = true '
                       + 'AND Event_Website__c <> null '
                       + 'AND ((StartDate >= :startOfMonth AND StartDate < :endOfMonth) OR (EndDate >= :startOfMonth AND EndDate < :endOfMonth))';
        try {
            for (Campaign camp : Database.query(query)) {
                results.add(new Event_Calendar_ResponseWrappers.CampaignWrapper(camp));
            }
            return new Event_Calendar_ResponseWrappers(true, CORRECT_MSG, results);
        } catch (Exception e) {
            return new Event_Calendar_ResponseWrappers(false, e.getMessage());
        }
    }

    public static Event_Calendar_ResponseWrappers getCampaignsSearch(String searchParameter) {
        List<Event_Calendar_ResponseWrappers.CampaignWrapper> results = new List<Event_Calendar_ResponseWrappers.CampaignWrapper>();
        String searchParamString = '\'' + searchParameter + '%\'';
        String searchParamList = '\'' + searchParameter + '\'';
        Id recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Cvent Campaign').getRecordTypeId();
        Date today = Date.today();
        String query = 'SELECT Id, Name, StartDate, EndDate, Segment__c, Event_Website__c, Status, Type, Country__c, State__c, City__c'
                       + ' FROM Campaign'
                       + ' WHERE IsActive = true AND StartDate >= :today'
                       + ' AND Event_Website__c <> null AND RecordTypeId = :recordTypeId'
                       + ' AND (Name LIKE ' + searchParamString + ' OR Type = ' + searchParamList
                       + ' OR City__c LIKE ' + searchParamString + ' OR State__c = ' + searchParamList
                       + ' OR Segment__c = ' + searchParamList + ')'
                       + ' ORDER BY Name';
        try {
            for (Campaign camp : Database.query(query)) {
                results.add(new Event_Calendar_ResponseWrappers.CampaignWrapper(camp));
            }
            return new Event_Calendar_ResponseWrappers(true, CORRECT_MSG, results, true);
        } catch (Exception e) {
            return new Event_Calendar_ResponseWrappers(false, e.getMessage());
        }
    }
}