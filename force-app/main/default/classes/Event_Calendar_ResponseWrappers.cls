global with sharing class Event_Calendar_ResponseWrappers { 

    public String message;
    public Boolean success;
    public List<BasicWrapper> dataList;
    public BasicWrapper data;
    public Integer numberOfRecords;

    public Event_Calendar_ResponseWrappers(Boolean success, String message,
                                           List<BasicWrapper> dataList, Boolean isSearch) {
        this.message = message;
        this.success = success;
        this.dataList = dataList;
        if (isSearch) this.numberOfRecords = this.dataList.size();
    }

    public Event_Calendar_ResponseWrappers(Boolean success, String message, List<BasicWrapper> dataList) {
        this.message = message;
        this.success = success;
        this.dataList = dataList;
    }

    public Event_Calendar_ResponseWrappers(Boolean success, String message, BasicWrapper data) {
        this.message = message;
        this.success = success;
        this.data = data;
    }

    public Event_Calendar_ResponseWrappers(Boolean success, String message) {
        this.message = message;
        this.success = success;
    }

    public abstract class BasicWrapper {}

    global class AttachmentWrapper extends BasicWrapper {

        public String name;
        public String attachmentId;

        public AttachmentWrapper(String name, String attachmentId) {
            this.name = name;
            this.attachmentId = attachmentId;
        }
    }

    global class CampaignDetailWrapper extends BasicWrapper {

        public String id;
        public String name;
        public Date startDate;
        public Date endDate;
        public String eventWebsite;
        public String segment;
        public String country;
        public String state;
        public String city;

        public CampaignDetailWrapper(Campaign camp) {
            this.id = camp.Id;
            this.name = camp.Name;
            this.startDate = camp.StartDate;
            this.endDate = camp.EndDate;
            this.segment = camp.Segment__c;
            this.country = camp.Country__c;
            this.state = camp.State__c;
            this.city = camp.City__c;
            this.eventWebsite = camp.Event_Website__c;
        }
    }

    global class CampaignWrapper extends BasicWrapper {

        public String id;
        public String name;
        public Date startDate;
        public Date endDate;
        public String segment;
        public String eventWebsite;
        public String status;
        public String type;
        public String country;
        public String state;
        public String city;

        public CampaignWrapper(Campaign camp) {
            this.id = camp.Id;
            this.name = camp.Name;
            this.startDate = camp.StartDate;
            this.endDate = camp.EndDate;
            this.segment = camp.Segment__c;
            this.eventWebsite = camp.Event_Website__c;
            this.status = camp.Status;
            this.type = camp.Type;
            this.country = camp.Country__c;
            this.state = camp.State__c;
            this.city = camp.City__c;
        }
    }

    global class CampaignsSearchWrapper extends BasicWrapper {

        public String id;
        public String name;
        public String city;
        public String segment;

        public CampaignsSearchWrapper(Campaign camp) {
            this.id = camp.Id;
            this.name = camp.Name;
            this.city = camp.City__c;
            this.segment = camp.Segment__c;
        }
    }
}