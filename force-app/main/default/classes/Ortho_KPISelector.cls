public with sharing class Ortho_KPISelector {
    public static List<String> fields = new List<String>{
        'KPI_Current__c',
        'KPI_Previous__c',
        'KPI_Target__c',
        'KPI_Type__c',
        'LastModifiedById',
        'Name',
        'OwnerId',
        'Product__c',
        'Timeframe__c',
        'KPI_Label__c'
    };

    public static List<Ortho_KPI__c> getKPIByUserAndType(Set<Id> userIds, Set<String> types){
        String query = String.format('SELECT {0} FROM Ortho_KPI__c WHERE OwnerId in: userIds and KPI_Type__c in: types order By KPI_Label__c asc',
                                     new List<Object>{String.join(fields, ',')});
        return (List<Ortho_KPI__c>)Database.query(query);
    }

    public static List<Ortho_KPI__c> getKPIByUserAndTypeAndProduct(Set<Id> userIds, Set<String> types, Set<String> products){
        String query = String.format('SELECT {0} FROM Ortho_KPI__c WHERE OwnerId in: userIds and KPI_Type__c in: types and Product__c in: products order By KPI_Label__c asc',
                                     new List<Object>{String.join(fields, ',')});
        return (List<Ortho_KPI__c>)Database.query(query);
    }

}