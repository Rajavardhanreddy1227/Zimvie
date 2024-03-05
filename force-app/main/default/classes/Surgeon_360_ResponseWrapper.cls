global with sharing class Surgeon_360_ResponseWrapper {
    public Boolean success;
    public String message;
    public Object data;
    public Integer numberOfElements;

    public Surgeon_360_ResponseWrapper(Boolean success, String message, List<Object> data) {
        this.success = success;
        this.message = message;
        this.data = data;
        this.numberOfElements = data.size();
    }

    public Surgeon_360_ResponseWrapper(Boolean success, String message, Object data) {
        this.success = success;
        this.message = message;
        this.data = data;
    }

    public Surgeon_360_ResponseWrapper(Boolean success, String message) {
        this.success = success;
        this.message = message;
    }

    public class SearchResultWrapper {
        public String First_Name;
        public String Last_Name;
        public String City;
        public String State;
        public String Country;
        public Id id;
        public String photo;

        public SearchResultWrapper(Account acc) {
            this.First_Name = acc.FirstName;
            this.Last_Name = acc.LastName;
            this.City = acc.PersonMailingCity;
            this.State = acc.PersonMailingState;
            this.Country = acc.PersonMailingCountry;
            this.id = acc.Id;
            if (acc.Account_Picture_Id__c != null) this.photo = '/servlet/servlet.FileDownload?file=' + acc.Account_Picture_Id__c;
        }
    }

    private class AddressWrapper {
        public String city;
        public String country;
        public String countryCode;
        public String postalCode;
        public String geocodeAccuracy;
        public String state;
        public String stateCode;
        public String street;

        public AddressWrapper(Address add) {
            this.city = add.City;
            this.country = add.Country;
            this.countryCode = add.CountryCode;
            this.postalCode = add.PostalCode;
            this.geocodeAccuracy = add.GeocodeAccuracy;
            this.state = add.State;
            this.stateCode = add.StateCode;
            this.street = add.Street;
        }
    }

    public class ProfileSummaryWrapper {
        public Decimal zbUsage;
        public Decimal marketUsage;
        public Decimal sunshinePayments;
        public Integer activePayers;
        public Integer campaigns;
        public Decimal opportunities;
        public Integer surgerySchedules;
        public Integer healthcareFacilityRelationships;
        public Integer publicEngagement;
        public Integer peerNetwork;
        public Integer activities;

        public ProfileSummaryWrapper(Decimal zbUsage, Decimal marketUsage,
                                     Decimal sunshinePayments, Integer activePayers,
                                     Integer campaigns, Decimal opportunities,
                                     Integer surgerySchedules, Integer healthcareFacilityRelationships,
                                     Integer publicEngagement, Integer peerNetwork,
                                     Integer activities) {
            this.zbUsage = zbUsage;
            this.marketUsage = marketUsage;
            if (sunshinePayments != null) this.sunshinePayments = (sunshinePayments / 1000).setScale(0);
            this.activePayers = activePayers;
            this.campaigns = campaigns;
            if (opportunities != null) this.opportunities = (opportunities / 1000).setScale(0);
            this.surgerySchedules = surgerySchedules;
            this.healthcareFacilityRelationships = healthcareFacilityRelationships;
            this.publicEngagement = publicEngagement;
            this.peerNetwork = peerNetwork;
            this.activities = activities;
        }
    }

    public class RatingWrapper {
        public Decimal value;
        public String label;
        public String translatedLabel;

        public RatingWrapper(Double value, String label, String translatedLabel) {
            this.value = Decimal.valueOf(value).setScale(1);
            this.label = label;
            this.translatedLabel = translatedLabel;
        }
    }

    public class AccountPersonalDataWrapper {
        public AddressWrapper personMailingAddress;
        public String photo;
        public String firstname;
        public Id id;
        public String lastName;

        public AccountPersonalDataWrapper(Address personMailingAddress, String photoId, Id id,
                                          String firstname, String lastName) {
            this.personMailingAddress = new AddressWrapper(personMailingAddress);
            if (photoId != null) this.photo = '/servlet/servlet.FileDownload?file=' + photoId;
            this.id = id;
            this.firstname = firstname;
            this.lastName = lastName;
        }
    }
}