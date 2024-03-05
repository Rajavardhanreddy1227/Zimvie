public with sharing class SegBreakoutSummary {
    public Decimal totalRevenue { get;  set;}
    
    public SegBreakoutSummary(ApexPages.StandardController controller) {
        
        String currentRecordId;
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        //System.debug('Current Opportunity in SegBreakoutSummary :' + currentRecordId);
        AggregateResult[] groupedResults = [SELECT SUM(Total_Revenue__c)ttlRev FROM Segmentation_Breakout__c where Segmentation_Opportunity__c = :currentRecordId];
        
        if (!groupedResults.isEmpty()) this.totalRevenue = (Decimal)groupedResults.get(0).get('ttlRev');
        System.debug('Total Revenue for Oppoprtunity : '+ currentRecordId + ' is '+totalRevenue);
    }
}