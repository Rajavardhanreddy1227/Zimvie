@isTest
private class ReSchedularTest {
    static testMethod void SchedularUnitTest() {   
        
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true );
        insert pb;
        
           Id standardPB = Test.getStandardPricebookId();
        
        Account acc = new Account();
        acc.Name='NewAcc';
        acc.BillingCity = 'Warsaw';
        acc.BillingState = 'IN';
        acc.BillingCountry = 'US';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name='NewOpp';
        opp.AccountId=acc.Id;
        opp.StageName='Prospecting';
        opp.Pricebook2Id = pb.Id;
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
        stdpbe.Pricebook2Id = standardPB;
       // stdpbe.Pricebook2Id = Test.getStandardPricebookId();
        stdpbe.UseStandardPrice=false;
        insert stdpbe;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id=Prod.Id;
        pbe.IsActive=True;
        pbe.UnitPrice=70;
        pbe.Pricebook2Id = oppt.Pricebook2Id;
        pbe.UseStandardPrice=false;
        insert pbe;
        
        OpportunityLineItem opli = new OpportunityLineItem();
        opli.UnitPrice = 57;
        opli.Quantity = 12;
        opli.OpportunityId=opp.Id;
        opli.PricebookEntryId=pbe.id;
        insert opli;
        
        
        list<OpportunityLineItemSchedule> insertoplisclist = new list<OpportunityLineItemSchedule>();
        for(integer i=0; i<15; i++){
            OpportunityLineItemSchedule olis = new OpportunityLineItemSchedule();
            olis.OpportunityLineItemId = opli.id;
            olis.quantity= 40;
            olis.revenue= 100.00;
            olis.type= 'Both';
            olis.ScheduleDate = Date.Today();
            insertoplisclist.add(olis);
        }
        insert insertoplisclist;
        Test.starttest();
            //Trigger will hit on this update    
            opp.CloseDate = opp.CloseDate.addDays(20);
            update opp;
   
        Test.stoptest();
    }
}