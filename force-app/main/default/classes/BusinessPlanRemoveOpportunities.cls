public class BusinessPlanRemoveOpportunities {
    public BusinessPlanRemoveOpportunities() {

    }

    public PageReference upload() {
        ApexPages.getMessages().clear();
        
        try {
            List<String> parentIds = ApexPages.currentPage().getParameters().get('id').split(',');
            List<Opportunity> updateOpp = new List<Opportunity>();
            for (Opportunity Opp : [SELECT ID, Product_Sales_Summary__c from Opportunity WHERE ID in :parentIds]) {
                opp.Product_Sales_Summary__c = null ; 
                updateOpp.add(Opp);
            }       
            if (updateOpp.size()>0){
                update updateOpp ; 

            }

            Apexpages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.CONFIRM, 'update successful.'));
            pagereference page = new PageReference ('/lightning/o/Business_Plan__c/list?filterName=Recent');
            return page ;
        } catch(Exception ex) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'There was an error while updating a record.'));
        }   

        return null;
    }
}