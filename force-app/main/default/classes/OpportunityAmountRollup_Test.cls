@isTest
public class OpportunityAmountRollup_Test {
    
    public static Account acc;
    public static Account acc2;
    public static Opportunity newOpp1;
    public static Opportunity newOpp2;
    
    @testSetup static void setup() {
        
        Trigger_Settings__c cs = new Trigger_Settings__c();
        cs.Name = 'BPTrigger_OpportunityAmountRollUp';
        cs.Active__c = true;
        insert cs;
        
        Id DisAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Distributor');
        
        acc = new Account();
       // acc.RecordTypeId = '012800000002ByTAAU';//Distributor
       acc.RecordTypeId = DisAccountTypeId;
        acc.Name = 'Joint Medical Concepts';
        acc.Territory_Number__c = '0044';
        insert acc;

        Id HealthAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','HealthcareFacility');
        
        acc = new Account();
      //  acc.RecordTypeId = '012800000002AW5AAM';//Distributor
        acc.RecordTypeId = HealthAccountTypeId;
        acc.Name = 'TEST ACCOUNT';
        acc.Territory_Number__c = '0018';
        insert acc;

        Business_Plan__c plan = new Business_Plan__c();
        plan.Name = 'Test Plan';
        plan.Active__c = TRUE;
        plan.Status__c = 'Active';
        plan.Year__c = 2022;
        plan.Territory_Account_Name__c = acc.Id;
        insert plan;
       
        Id PhyAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Physician');
        
        acc2 = new Account();
      //  acc2.RecordTypeId = '012800000002C4gAAE';//person account
        acc2.RecordTypeId = PhyAccountTypeId;
        acc2.LastName = 'Alex';
        acc2.FirstName = 'Test';
        acc2.PersonMailingCountry = 'US'; 
        acc2.PersonMailingCity = 'Warsaw';
        acc2.PersonMailingState = 'IN'; 
        acc2.PersonMailingStreet =' E Main St'; 
        acc2.PersonMailingPostalCode = '46582'; 
        insert acc2;
        
        Business_Plan__c plan2 = new Business_Plan__c();
        plan2.Name = 'Test Plan Terr 0044';
        plan2.Active__c = TRUE;
        plan2.Status__c = 'Active';
        plan2.Year__c = 2022;
        plan2.Territory_Account_Name__c = acc2.Id;
        insert plan2;
        
        List<String> prds = new String[] {'Hips', 'Knees', 'Sports Medicine', 'Extremities', 'Foot & Ankle', 'Trauma', 'Cement', 'Early Intervention'};
        
        for (String p: prds) {
            
                Product_Sales_Summary__c pSummary = new Product_Sales_Summary__c();
                pSummary.Name = 'Test Product Sales Summary for '+p;
                pSummary.Business_Plan__c = plan.Id;
                pSummary.Product_Group__c = p;
                insert pSummary;
            	System.debug('Adding Prd Plan for :'+'Test Product Sales Summary for '+p);
            
            if (p != 'Early Intervention' && p!='Cement') {
            Market_Segmentation__c marketseg = new Market_Segmentation__c ();
            marketseg.Surgeon_Name__c = acc2.id; 
            marketseg.Segementation__c = 'Gold';
            marketseg.Product_Group__c = p;
            marketseg.Master_Territory_ID__c = acc.id ; 
            marketseg.Zimmer_Biomet_Procedures__c = 100; 
            marketseg.Market_Procedures__c = 150;
            insert  marketseg ; 
             }   
             
        } 
       
    }
    
    static testMethod void validateOpportunitybeforeInsert() {         
        
        Account acct = [select Id,Name from account where Name=:'TEST ACCOUNT'];
        Account acct2 = [select Id,Name,LastName, FirstName from account where LastName = 'Alex' and FirstName = 'Test'];
        //Product_Sales_Summary__c pKneesSales = [Select Id, Name from Product_Sales_Summary__c where Name=:'Test Knees Sales Summary'];
        //Product_Sales_Summary__c pHipsSales = [Select Id, Name from Product_Sales_Summary__c where Name=:'Test Hips Sales Summary'];
        
        List<String> prds = new String[] {'Hips', 'Knees', 'Sports Medicine', 'Extremities', 'Foot & Ankle', 'Trauma', 'Cement', 'Early Intervention'};
        List<Opportunity> lstOppty = new List<Opportunity>();
        List<Opportunity> lstOppToUpd = new List<Opportunity>();
        
        for (String p: prds) {
            	String nm = 'Test Product Sales Summary for '+p;
            	System.debug(nm);
                Product_Sales_Summary__c pSummary = [Select Id, Name from Product_Sales_Summary__c where Name=:nm];
            	
            	String rectypeName ; 
                rectypeName = p == 'Hips' ? 'US Hip' 
                            : p == 'Knees'? 'US Knee' 
                            : p == 'Sports Medicine' ? 'US Sports Medicine'  
                            : p == 'Extremities' ? 'US Extremities'  
                            : p == 'Foot & Ankle' ? 'US Foot and Ankle' 
                            : p == 'Trauma' ? 'US Trauma' 
                            : p == 'Cement' ? 'US Cement' 
                            : p == 'Early Intervention' ? 'US Early Intervention' 
                            : '';
            
            	String recType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(rectypeName).getRecordTypeId();
            	System.debug('Creating Opportunity of Type :'+recTypeName+ ' and RecordType Id = '+recType);
            	//Create Oppty
                newOpp2 = new Opportunity();
                newOpp2.Name = 'Test Opp for '+p;
                newOpp2.Amount = 5000;
                newOpp2.AccountId = acct.Id;
                newOpp2.StageName = 'Target';
                newOpp2.CloseDate = date.today().addDays(30);
                newOpp2.RecordTypeId = recType;
                newOpp2.Surgeon_Name__c = acct2.Id;
                newOpp2.At_Risk__c = TRUE;
                newOpp2.BP_Target__c = TRUE;
                newOpp2.Territory_Name__c = 'Joint Medical Concepts';
                newOpp2.Product_Sales_Summary__c = pSummary.Id;  //ref Product_Sales_Summary__c 
            
            	lstOppty.add(newOpp2);
                
        } 
        
        insert lstOppty;
        
        test.startTest();
        
        List<Opportunity> lstNewOpps = [Select Id, Name, stageName from Opportunity where Id=:lstOppty];
        for (Opportunity o : lstNewOpps) {
            System.debug('Going to update Stage Name to Closed Lost for Opportunity '+o.Name);
            
            o.StageName = 'Closed Lost';
            lstOppToUpd.add(o);
        }
        
        update lstOppToUpd;
        
        test.stopTest();
        
        /*
        list<Opportunity> oppList = new list<Opportunity>();
        
        for (integer i=0;i<5;i++){
            Opportunity newOpp = new Opportunity();
            newOpp.Name = 'Test Opp-'+i;
            newOpp.Amount = 5000; 
            newOpp.AccountId = acct.Id;
            newOpp.StageName = 'Target';
            newOpp.CloseDate = date.today().addDays(30);
            newOpp.RecordTypeId = '012800000002ReS';
            newOpp.Surgeon_Name__c = acct2.Id;
            if(i==3 || i==5 || i==7){ newOpp.At_Risk__c = FALSE;}
            else{ newOpp.At_Risk__c = TRUE; }
            newOpp.BP_Target__c = TRUE;
            newOpp.Territory_Name__c = 'APEX SURGICAL(FOX-GATTEN)';
            newOpp.Product_Sales_Summary__c = pKneesSales.Id;  //ref Product_Sales_Summary__c
            oppList.add(newOpp);
        }
        
        insert oppList; 
        
        newOpp1 = new Opportunity();
        newOpp1.Name = 'Test Opp';
        newOpp1.Amount = 5000;
        newOpp1.AccountId = acct.Id;
        newOpp1.StageName = 'Target';
        newOpp1.CloseDate = date.today().addDays(30);
        newOpp1.RecordTypeId = '012800000002ReS';
        newOpp1.Surgeon_Name__c = acct2.Id;
        newOpp1.At_Risk__c = FALSE;
        newOpp1.BP_Target__c = TRUE;
        newOpp1.Territory_Name__c = 'Joint Medical Concepts';
        newOpp1.Product_Sales_Summary__c = pKneesSales.Id;  //ref Product_Sales_Summary__c
        insert newOpp1;
        */
        
        /* Commented on 9/23/2021
        newOpp2 = new Opportunity();
        newOpp2.Name = 'Test Opp';
        newOpp2.Amount = 5000;
        newOpp2.AccountId = acct.Id;
        newOpp2.StageName = 'Target';
        newOpp2.CloseDate = date.today().addDays(30);
        newOpp2.RecordTypeId = '012800000002ReS';
        newOpp2.Surgeon_Name__c = acct2.Id;
        newOpp2.At_Risk__c = TRUE;
        newOpp2.BP_Target__c = TRUE;
        newOpp2.Territory_Name__c = 'Joint Medical Concepts';
        newOpp2.Product_Sales_Summary__c = pHipsSales.Id;  //ref Product_Sales_Summary__c 
        insert newOpp2;
        
        test.startTest();
        
        Opportunity opp2 = [Select Id, Name, stageName from Opportunity where Id=:newOpp2.Id];
        opp2.StageName = 'Closed Lost';
        update opp2 ; 
        
        
        //Create 
        test.stopTest();
		*/
    }
    /*
    static testMethod void validateOpportunitybeforeUpdate() {
        
        test.startTest();
        
        Account acct = [select Id,Name from account where Name=:'APEX SURGICAL(FOX-GATTEN)'];
        Account acct2 = [select Id,Name,LastName, FirstName from account where LastName = 'Alex' and FirstName = 'Test'];
        
        Product_Sales_Summary__c pKneesSales = [Select Id, Name from Product_Sales_Summary__c where Name=:'Test Knees Sales Summary'];
        Product_Sales_Summary__c pHipsSales = [Select Id, Name from Product_Sales_Summary__c where Name=:'Test Hips Sales Summary'];
        newOpp1 = new Opportunity();
        newOpp1.Name = 'Test Opp';
        newOpp1.AccountId = acct.Id;
        newOpp1.StageName = 'Target';
        newOpp1.CloseDate = date.today().addDays(30);
        newOpp1.RecordTypeId = '012800000002ReS';
        newOpp1.Surgeon_Name__c = acct2.Id;
        newOpp1.At_Risk__c = TRUE;
        newOpp1.BP_Target__c = TRUE;
        newOpp1.Territory_Name__c = 'APEX SURGICAL(FOX-GATTEN)';
        newOpp1.Product_Sales_Summary__c = pKneesSales.Id;  //ref Product_Sales_Summary__c
        insert newOpp1;
        
        newOpp2 = new Opportunity();
        newOpp2.Name = 'Test Opp';
        newOpp2.AccountId = acct.Id;
        newOpp2.StageName = 'Target';
        newOpp2.CloseDate = date.today().addDays(30);
        newOpp2.RecordTypeId = '012800000002ReS';
        newOpp2.Surgeon_Name__c = acct2.Id;
        newOpp2.At_Risk__c = TRUE;
        //newOpp2.BP_Target__c = TRUE;
        newOpp2.Territory_Name__c = 'APEX SURGICAL(FOX-GATTEN)';
        newOpp2.Product_Sales_Summary__c = pHipsSales.Id;  //ref Product_Sales_Summary__c 
        insert newOpp2;
        Opportunity opp1 = [Select Id, Name from Opportunity where Id=:newOpp1.Id];
        opp1.StageName = 'Closed Lost';
        opp1.BP_Target__c = TRUE;
        opp1.At_Risk__c = TRUE;
        opp1.Product_Sales_Summary__c = pHipsSales.Id;  //ref Product_Sales_Summary__c
        update opp1;
        
        Opportunity opp2 = [Select Id, Name from Opportunity where Id=:newOpp2.Id];
        opp2.StageName = 'Closed Lost';
        opp2.BP_Target__c = TRUE;
        opp2.At_Risk__c = FALSE;
        opp2.Surgeon_Name__c = acct2.id ; 
        opp1.At_Risk__c = TRUE;
        Opp2.probability = 75 ; 
        Opp2.amount = 10000;
        //opp2.Product_Sales_Summary__c = pHipsSales.Id;  //ref Product_Sales_Summary__c
        update opp2;        
        test.stopTest();
        
    }*/
    
    
}