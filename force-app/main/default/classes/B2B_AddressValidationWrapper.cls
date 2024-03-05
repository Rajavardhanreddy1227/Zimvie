public with sharing class B2B_AddressValidationWrapper {
    @AuraEnabled public Boolean enableUspsCass;
    @AuraEnabled public RequestAddress address;

    public class RequestAddress{
        @AuraEnabled public String regionCode;
        @AuraEnabled public String locality;
        @AuraEnabled public String administrativeArea;
        @AuraEnabled public String postalCode;
        @AuraEnabled public List<String> addressLines;
    }
    
}