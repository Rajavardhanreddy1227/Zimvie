public with sharing class Ortho_KPIController {
    @AuraEnabled(cacheable = true)
    public static Ortho_KPI getProductData(String product){

        List<Ortho_KPI__c> orthoKPIs = Ortho_KPISelector.getKPIByUserAndTypeAndProduct(new Set<Id>{UserInfo.getUserId()}, new Set<String>{'Target'}, new Set<String>{product});
        Ortho_KPI oKPI = new Ortho_KPI();
        for(Ortho_KPI__c kpi : orthoKPIs){
            if(kpi.Timeframe__c == 'Monthly'){
                oKPI.monthly = kpi;
            }
            if(kpi.Timeframe__c == 'Quarterly'){
                oKPI.quarterly = kpi;
            }
            if(kpi.Timeframe__c == 'Yearly'){
                oKPI.yearly = kpi;
            }
            if(kpi.Timeframe__c == 'Yearly - Without Quarter'){
                oKPI.yearlyWithoutQtr = kpi;
            }
        }
        return oKPI;
    }

    public class Ortho_KPI {
        @AuraEnabled
        public Ortho_KPI__c monthly {get;set;}
        @AuraEnabled
        public Ortho_KPI__c quarterly {get;set;}
        @AuraEnabled
        public Ortho_KPI__c yearly {get;set;}
        @AuraEnabled
        public Ortho_KPI__c yearlyWithoutQtr {get;set;}
    }
}