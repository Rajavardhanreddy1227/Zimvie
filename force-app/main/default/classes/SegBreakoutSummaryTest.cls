@isTest
private class SegBreakoutSummaryTest {
    
    //Create Opportunity
    //
    //Create Segmentation Breakout
    //
    //Check Total
    //
    @isTest static void checkSegBreakoutSummary() {
        Trigger_Settings__c cs = new Trigger_Settings__c();
        cs.Name = 'BPTrigger_OpportunityAmountRollUp';
        cs.Active__c = true;
        insert cs;

        Id disRTypeId = RecordTypeHelper.getRecordTypeId('Account','DN_ISR_ACCT');
        
        Account acc = new Account();
        acc.RecordTypeId = disRTypeId;
       // acc.RecordTypeId = '012800000002AW5AAM';//Distributor
        acc.Name = 'Test Healthcare Facility';
        acc.Status__c = 'A';
        insert acc;

        /*
       
        acc2 = new Account();
        acc2.RecordTypeId = '012800000002C4gAAE';//person account
        acc2.LastName = 'Alex';
        acc2.FirstName = 'Test';
        acc2.PersonMailingCountry = 'US'; 
        acc2.PersonMailingCity = 'Warsaw';
        acc2.PersonMailingState = 'IN'; 
        acc2.PersonMailingStreet =' E Main St'; 
        acc2.PersonMailingPostalCode = '46582'; 
        insert acc2;

        */
       list<Opportunity> oppList = new list<Opportunity>();
        
        Id rosaRTypeId = RecordTypeHelper.getRecordTypeId('Opportunity','ROSA');
        
        
        
        //for (integer i=0;i<1;i++){
            Opportunity newOpp = new Opportunity();
            newOpp.Name = 'Test Oppty - Rosa SB';
            newOpp.Amount = 5000; 
            newOpp.AccountId = acc.Id;
            newOpp.StageName = 'Target';
            newOpp.CloseDate = date.today().addDays(30);
            newOpp.RecordTypeId = rosaRTypeId;
           // newOpp.RecordTypeId = '012C0000000YQqaIAG';
            //newOpp.Surgeon_Name__c = acct2.Id;
            //newOpp.BP_Target__c = TRUE;
            //newOpp.Territory_Name__c = 'APEX SURGICAL(FOX-GATTEN)';
            //newOpp.Product_Sales_Summary__c = pKneesSales.Id;  //ref Product_Sales_Summary__c
            
            //oppList.add(newOpp);
            newOpp.At_Risk__c = TRUE;
        	insert newOpp;
            
            //Create Segmentation Breakout Record
            //
            List<Segmentation_Breakout__c> sbList = new List<Segmentation_Breakout__c>();
            
            for (integer j=1;j<=5;j++) {
              Segmentation_Breakout__c sb = new Segmentation_Breakout__c();
                
                sb.Segmentation_Opportunity__c	= newOpp.id;
                sb.Case_Quantity__c	= j*2;
                sb.Name	= 'SB for Oppty -> '+j;
                sb.Price_Point__c	= j*1000;
                sb.Surgeon__c	= acc.id;
                
                if (j==1 || j == 5) {
                    sb.Type__c = 'Growth';
                    sb.Product_Segment__c	= 'Knees';
                    sb.Primary_Competitor__c = 'Aecuaos';
            	}
                else {
                    sb.Type__c = 'ZB Transfer';
                    sb.Product_Segment__c	= 'Hips';
                }
                
                sbList.add(sb);
            }
            insert sbList;      
        
			// Verify Count of SB for Oppty
			List<Segmentation_Breakout__c> lstSB = [Select Id, Case_Quantity__c, Price_Point__c, Total_Revenue__c, Product_Segment__c from Segmentation_Breakout__c where Segmentation_Opportunity__c = :newOpp.Id];
        
        	System.assert(lstSB.size() ==5);
        	/*PageReference pageRef = Page.OpptySegmentationBreakout;
        	Test.setCurrentPageReference (pageRef);
        	ApexPages.currentPage().getParameters().put('id', newOpp.Id);
        	SegBreakoutSummary controller = new SegBreakoutSummary(new ApexPages.StandardController( newOpp));*/
        
        	SegBreakoutSummary sc = new SegBreakoutSummary(new ApexPages.StandardController( newOpp));
        	System.debug('Total Amt should be '+sc.totalRevenue);
        	System.assertEquals(sc.totalRevenue, null);
    }   
}