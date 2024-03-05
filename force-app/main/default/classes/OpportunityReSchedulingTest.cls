@isTest
private class OpportunityReSchedulingTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Test.starttest();
        
        Id accId = RecordTypeHelper.getRecordTypeId('Account','DN_ISR_ACCT');
       
            system.debug('check in accountid' + accId);
        	Account acc = new Account();
        	acc.Name='NewAcc';
            acc.RecordTypeId = accId;
        	insert acc;

        	Opportunity opp = new Opportunity();
        	opp.Name='NewOpp';
        	opp.AccountId=acc.Id;
        	opp.StageName='Prospecting';
        	opp.CloseDate=Date.today().addDays(10);
        	insert opp;

	       	 Opportunity oppt = [select Id, Name, Pricebook2Id from Opportunity where Name=:'NewOpp'];
        system.debug('-----Oppt Pricebook---'+oppt.Pricebook2Id);
        
        Product2 Prod =  new Product2();
        Prod.Name='NewProd';
        Prod.IsActive=True;
        prod.CanUseQuantitySchedule = True;
        prod.CanUseRevenueSchedule = True;
        insert Prod;
        
        PricebookEntry stdpbe = new PricebookEntry();
        stdpbe.Product2Id=Prod.Id;
        stdpbe.IsActive=True;
        stdpbe.UnitPrice=70;
        stdpbe.Pricebook2Id = Test.getStandardPricebookId();
        stdpbe.UseStandardPrice=false;
        insert stdpbe;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id=Prod.Id;
        pbe.IsActive=True;
        pbe.UnitPrice=70;
        pbe.Source_External_id__c ='000000000000000';
        pbe.Pricebook2Id = oppt.Pricebook2Id;
        pbe.UseStandardPrice=false;
  //      insert pbe;
        	
        	opp.CloseDate = opp.CloseDate.addDays(20);
        	update opp;
        	
        
        Test.stoptest();
    }
}