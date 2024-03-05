@isTest
public class BPSurgeonSelectionControllerTest {
    public static Account acc;
    public static Account acc2;
    public static Opportunity newOpp1;
    public static Opportunity newOpp2;
    
    @testSetup static void setup() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        RecordType rt = [SELECT Id,Name,SobjectType FROM RecordType WHERE Name LIKE '%Healthcare Facility%'];
        
        acc = new Account();
       // acc.RecordTypeId = '012800000002AW5AAM';//Healthcare Facility
        acc.RecordTypeId = rt.Id;
        acc.Name = 'APEX SURGICAL(FOX-GATTEN)';
        acc.RVP__c = u.Id;
        insert acc;


        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@testorg.com');
        RecordType rt1 = [SELECT Id,Name,SobjectType FROM RecordType WHERE Name LIKE '%Physician%' AND SobjectType = 'Account'];
        
        acc2 = new Account();
      //  acc2.RecordTypeId = '012800000002C4gAAE';//person account
        acc2.RecordTypeId = rt1.Id;
        acc2.LastName = 'Alex';
        acc2.FirstName = 'Test';
        acc2.PersonMailingCountry = 'US'; 
        acc2.PersonMailingCity = 'Warsaw';
        acc2.PersonMailingState = 'IN'; 
        acc2.PersonMailingStreet =' E Main St'; 
        acc2.PersonMailingPostalCode = '46582'; 
        insert acc2;
        
        Business_Plan__c plan = new Business_Plan__c();
        plan.Name = 'Test Plan';
        plan.Active__c = TRUE;
        plan.Status__c = 'Active';
        plan.Year__c = 2020;
        plan.Quarter__c = 'Second';
        plan.Territory_Account_Name__c = acc.Id;
        insert plan;
        
        Annual_Sales_Data__c annualSales = new Annual_Sales_Data__c();
        annualSales.Territory_Name__c = acc.Id;
        annualSales.Year__c = 2020;
        annualSales.This_Year_YTD_Sales_Thru_Month__c = 15000;
        annualSales.Y_1_Sales__c = 10000; 
        insert annualSales;
        
        Product_Sales_Summary__c pSummary = new Product_Sales_Summary__c();
        pSummary.Name = 'Test Knees Sales Summary';
        pSummary.Business_Plan__c = plan.Id;
        pSummary.Product_Group__c = 'Knees';
        pSummary.This_Quarter_Projection__c = 10000;
        pSummary.Pricing_Impact__c = 10;
        pSummary.Vol_Mix_Impact__c = 5;
        pSummary.Opportunities__c = 7500;
        pSummary.BD_Y__c = 253;
        pSummary.BD_Y_1__c = 252;
        pSummary.Risks__c = 1000;
        pSummary.Annual_Sales_Data__c = annualSales.id;
        insert pSummary;
                      
        Product_Sales_Summary__c pSummary2 = new Product_Sales_Summary__c();
        pSummary2.Name = 'Test Hips Sales Summary';
        pSummary2.Business_Plan__c = plan.Id;
        pSummary2.Product_Group__c = 'Hips';
        pSummary2.This_Quarter_Projection__c = 14000;
        pSummary2.Pricing_Impact__c = 14;
        pSummary2.Vol_Mix_Impact__c = 5;
        pSummary2.BD_Y__c = 253;
        pSummary2.BD_Y_1__c = 252;
        pSummary2.Opportunities__c = 9500;
        pSummary2.Risks__c = 3000;
        pSummary2.Annual_Sales_Data__c = annualSales.id;
        insert pSummary2;

        Market_Segmentation__c marketseg = new Market_Segmentation__c ();
        marketseg.Surgeon_Name__c = acc2.id; 
        marketseg.Segementation__c = 'Gold';
        marketseg.Product_Group__c = 'Knees';
        marketseg.Master_Territory_ID__c = acc.id ; 
        marketseg.Zimmer_Biomet_Procedures__c = 100; 
        marketseg.Market_Procedures__c = 150;
        insert  marketseg ; 

    }
    
    static testMethod void validate_BusinessPlanSurgeonSelector() {
        
        test.startTest();
        
        Account acct = [select Id,Name from account where Name=:'APEX SURGICAL(FOX-GATTEN)'];
        
        Business_Plan__c bPlan = [select Id, Name, Active__c, Year__c from Business_Plan__c];

        List<Market_Segmentation__c> lstmktseg = [SELECT id, Surgeon_Name__c, Aligned_Team__c, Surgeon_Name__r.name, Segementation__c,Product_Group__c,Master_Territory_ID__c, Zimmer_Biomet_Procedures__c from Market_Segmentation__c
                                                 Limit 1 ];
        
        Product_Sales_Summary__c pKneesSales = [Select Id, Name from Product_Sales_Summary__c where Name=:'Test Knees Sales Summary'];
        Product_Sales_Summary__c pHipsSales = [Select Id, Name from Product_Sales_Summary__c where Name=:'Test Hips Sales Summary'];
        
        pKneesSales.Opportunities__c = 120012;
        update pKneesSales;
        BPSurgeonSelectionController bPController = new BPSurgeonSelectionController();
        BPSurgeonSelectionController.fetchAccountWrapper(bPlan.id,'Knees','Product_Group__c', TRUE,'Alex','Gold');
        BPSurgeonSelectionController.fetchAccountWrapper(bPlan.id,'Knees','Product_Group__c', FALSE,'Alex','Gold');
        BPSurgeonSelectionController.createOpportunities(lstmktseg, bPlan.id);
        test.stopTest();
        
    }
}