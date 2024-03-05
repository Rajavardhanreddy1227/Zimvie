public with sharing class businessPlanExecutiveSummary {
    public Executive_Summary__c ExeSum {get;set;}
    @AuraEnabled (cacheable=true)
    public static Executive_Summary__c getActiveExecutiveSummary(string bpid){
        Executive_Summary__c exsummary = [select    id
                                                    , Question_Type__c
                                                    , IsActive__c 
                                                    , Executive_Summary_fld__c 
                                                    , Business_Plan__c
                                        from        Executive_Summary__c
                                        where       Business_Plan__c = :bpid
                                        and         IsActive__c = true 
                                        LIMIT 1];
        return exsummary; 
    } 
    public businessPlanExecutiveSummary(ApexPages.StandardController controller){
        string bpid ;
        bpid =  ApexPages.currentPage().getParameters().get('id');
        system.debug('BPid--->>'+bpid);
        ExeSum = [select    id
                                                    , Question_Type__c
                                                    , IsActive__c 
                                                    , Executive_Summary_fld__c 
                                                    , Business_Plan__c
                                        from        Executive_Summary__c
                                        where       Business_Plan__c = :bpid
                                        and         IsActive__c = true 
                                        LIMIT 1];
         system.debug('ExeSum--->>'+ExeSum);
    } 
}