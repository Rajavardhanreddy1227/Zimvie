public class BusinessPlanApprovalController {    
    @auraEnabled
    public static string submitAndProcessApprovalRequest(String recordId, String comment) {
        string response;
        Id Userid=UserInfo.getUserId();
        try{
            recordId = String.escapeSingleQuotes(recordId);
            comment = String.escapeSingleQuotes(comment);
            Id idToProccess = recordId;
            Schema.sObjectType entityType = idToProccess.getSObjectType();
            system.debug('entityType:::'+entityType);
            String entity = String.valueOf(entityType);
            List<ProcessDefinition> appProcessName = new List<ProcessDefinition>([SELECT Id,Name,TableEnumOrId,State,DeveloperName from ProcessDefinition where TableEnumOrId=: entity and State='Active']);
            
            if(appProcessName.isEmpty()){
                response = 'failure';
            }
            else{
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                if(string.isNotBlank(comment) && comment != null)
                {
                    req1.setComments(comment);
                }
                req1.setObjectId(recordId);
                req1.setSubmitterId(Userid); 
                req1.setProcessDefinitionNameOrId(appProcessName[0].DeveloperName);
                Approval.ProcessResult result = Approval.process(req1);
                response = 'success';
            }
        }
        catch(System.DmlException ex){
            system.debug('Error Message ::: ' + Ex.getMessage() + ' Due to this issues ::: ' + Ex.getLineNumber());   
            response = Ex.getMessage(); 
        }
        return response;
    }
    @auraEnabled
    public static string approvalProcessStatus(String recordId) {
        string response;
        recordId = String.escapeSingleQuotes(recordId);
        Id sId = (Id)recordId;
        Integer HdCnt;
        
        HdCnt = 0;
        
        //Check if object is of Type Business Plan and it has no Headcount Summary Records
        String sobjectType = sId.getSObjectType().getDescribe().getName();
        
        System.debug('The sObject is :'+sobjectType);
        
        //Get HeadCount Summary records
        List<Headcount_Summary__c> lHCS = [Select Id, This_Year_End_Estimate__c, Q1_Planned_Hires__c, Q2_Planned_Hires__c, Q3_Planned_Hires__c, Q4_Planned_Hires__c from Headcount_Summary__c where Business_Plan__c = :sId];
        
        for (Headcount_Summary__c h : lHCS) {
            if (h.This_Year_End_Estimate__c != null && h.This_Year_End_Estimate__c > 0)
                HdCnt += Integer.valueOf(h.This_Year_End_Estimate__c);            
        }
        
        System.debug('Headcount Summary Records = '+HdCnt);
        
        if (HdCnt > 0) {
            //Taking out already running Approval Process.
            List<ProcessInstance> appProcessList = [Select Id, Status From ProcessInstance WHERE TargetObjectId =: recordId and Status != 'Rejected' LIMIT 1];
            if(appProcessList.size()==0){
                response = 'success';
            }
            else{
                response = 'failure';
            }
            system.debug('response::'+response);
        }
        else
        {
            response = 'failure-headcount';
        }
        return response;
    }
    
   
}