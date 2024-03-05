@isTest
public class BusinessPlanRemoveOpportunities_Test {
    
    public static Account acc;
    public static Opportunity newOpp1;
    public static Opportunity newOpp2;
    
    @testSetup static void setup() {
        RecordType rt = [SELECT Id,Name,SobjectType FROM RecordType WHERE Name LIKE '%Healthcare Facility%']; 
        
        acc = new Account();

       // acc.RecordTypeId = '012800000002AW5AAM';//Healthcare Facility
        acc.RecordTypeId = rt.Id;
        acc.Name = 'APEX SURGICAL(FOX-GATTEN)';
        insert acc;
        
        Business_Plan__c plan = new Business_Plan__c();
        plan.Name = 'Test Plan';
        plan.Active__c = TRUE;
        plan.Status__c = 'Active';
        plan.Year__c = 2019;
        plan.Territory_Account_Name__c = acc.Id;
        insert plan;
      
        Product_Sales_Summary__c pSummary = new Product_Sales_Summary__c();
        pSummary.Name = 'Test Knees Sales Summary';
        pSummary.Business_Plan__c = plan.Id;
        pSummary.Product_Group__c = 'Knees';
        insert pSummary;
        
        Product_Sales_Summary__c pSummary2 = new Product_Sales_Summary__c();
        pSummary2.Name = 'Test Hips Sales Summary';
        pSummary2.Business_Plan__c = plan.Id;
        pSummary2.Product_Group__c = 'Hips';
        insert pSummary2;
    }
    
    static testMethod void validate_BusinessPlanRemoveOpportunities() {
        
        test.startTest();
        
        Account acct = [select Id,Name from account where Name=:'APEX SURGICAL(FOX-GATTEN)'];
        
        Product_Sales_Summary__c pKneesSales = [Select Id, Name from Product_Sales_Summary__c where Name=:'Test Knees Sales Summary'];
        Product_Sales_Summary__c pHipsSales = [Select Id, Name from Product_Sales_Summary__c where Name=:'Test Hips Sales Summary'];
        
        RecordType rt1 = [SELECT Id,Name,SobjectType FROM RecordType WHERE Name LIKE '%US Knee%'];
        
        newOpp1 = new Opportunity();
        newOpp1.Name = 'Test Opp';
        newOpp1.Amount = 5000;
        newOpp1.AccountId = acct.Id;
        newOpp1.StageName = 'Target';
        newOpp1.CloseDate = date.today().addDays(30);
        newOpp1.RecordTypeId = rt1.Id;
        newOpp1.Surgeon_Name__c = acct.Id;
        newOpp1.At_Risk__c = TRUE;
        newOpp1.BP_Target__c = TRUE;
        newOpp1.Territory_Name__c = 'ZB APEX Surgical';
        newOpp1.Product_Sales_Summary__c = pKneesSales.Id;  //ref Product_Sales_Summary__c
        insert newOpp1;
        
        newOpp2 = new Opportunity();
        newOpp2.Name = 'Test Opp';
        newOpp2.Amount = 5000;
        newOpp2.AccountId = acct.Id;
        newOpp2.StageName = 'Target';
        newOpp2.CloseDate = date.today().addDays(30);
        newOpp2.RecordTypeId = rt1.Id;
        newOpp2.Surgeon_Name__c = acct.Id;
        newOpp2.At_Risk__c = TRUE;
        //newOpp2.BP_Target__c = TRUE;
        //newOpp2.Territory_Name__c = 'APEX SURGICAL(FOX-GATTEN)';
        newOpp2.Product_Sales_Summary__c = pHipsSales.Id;  //ref Product_Sales_Summary__c 
        insert newOpp2;
        
        Opportunity opp1 = [Select Id, Name from Opportunity where Id=:newOpp1.Id];
        Opportunity opp2 = [Select Id, Name from Opportunity where Id=:newOpp2.Id];
        
        String parentIds = opp1.Id+','+opp2.Id;
        
        ApexPages.currentpage().getparameters().put('id' , parentIds);
        BusinessPlanRemoveOpportunities removeOpps = new BusinessPlanRemoveOpportunities();
        removeOpps.upload();
        
        test.stopTest();
        
    }   
}