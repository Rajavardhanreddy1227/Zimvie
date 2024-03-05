@isTest
public class ChartController_Test {
    
    public static Account acc;
    public static Opportunity newOpp1;
    public static Opportunity newOpp2;
    
    @testSetup static void setup() {
        
        RecordType rt = [SELECT Id,Name,SobjectType FROM RecordType WHERE Name LIKE '%Physician%' AND SobjectType = 'Account'];
        
        acc = new Account();
       // acc.RecordTypeId = '012800000002C4gAAE';//Physician
        acc.RecordTypeId = rt.Id;
        acc.FirstName = 'Test';
        acc.LastName = 'Acc';
        acc.Salutation = 'Dr.';
        acc.PersonMailingStreet = 'Suite 200,1501 Maple Avenue';
        acc.PersonMailingCity = 'Richmond';
        acc.PersonMailingCountry = 'US';
        acc.PersonMailingPostalCode = '23226';
        acc.PersonMailingState = 'VA';
        insert acc;
        
        Business_Plan__c plan = new Business_Plan__c();
        plan.Name = 'Test Plan';
        plan.Active__c = TRUE;
        plan.Status__c = 'Active';
        plan.Year__c = 2019;
        plan.Territory_Account_Name__c = acc.Id;
        insert plan;
        
        Annual_Sales_Data__c annualSales = new Annual_Sales_Data__c();
        annualSales.Territory_Name__c = acc.Id;
        annualSales.Year__c = 2020;
        annualSales.This_Year_YTD_Sales_Thru_Month__c = 15000;
        annualSales.Y_1_Sales__c = 10000;
        annualSales.Full_Year_Target__c = 5000;
        annualSales.This_Year_YTD_Sales_Thru_Month__c = 3000;
        insert annualSales;
        
        Product_Sales_Summary__c pSummary = new Product_Sales_Summary__c();
        pSummary.Name = 'Test Knees Sales Summary';
        pSummary.Business_Plan__c = plan.Id;
        pSummary.Product_Group__c = 'Knees';
        pSummary.This_Quarter_Projection__c = 4000;
        pSummary.Pricing_Impact__c = 10;
        pSummary.Opportunities__c = 15000;
        pSummary.Risks__c = 2000;
        insert pSummary;
        
		RecordType rt1 = [SELECT Id,Name,SobjectType FROM RecordType WHERE Name LIKE '%US OBT%'];
        
        newOpp1 = new Opportunity();
        newOpp1.Name = 'Test Opp';
        newOpp1.Amount = 5000;
        newOpp1.AccountId = acc.Id;
        newOpp1.StageName = 'Target';
        newOpp1.CloseDate = date.today().addDays(30);
        newOpp1.RecordTypeId = rt1.Id;
        newOpp1.Surgeon_Name__c = acc.Id;
        newOpp1.At_Risk__c = TRUE;
        newOpp1.BP_Target__c = TRUE;
      //  newOpp1.Territory_Name__c = 'ZB Empire';
        newOpp1.Product_Sales_Summary__c = pSummary.Id;  //ref Product_Sales_Summary__c
        insert newOpp1;
        
        Market_Segmentation__c mkt = new Market_Segmentation__c();
        mkt.Zimmer_Biomet_Procedures__c = 5;
        mkt.Market_Procedures__c = 5;
        mkt.Surgeon_Name__c = acc.Id;
        mkt.Product_Group__c = 'Knees';
        mkt.Segementation__c = 'Gold';
        insert mkt;
    }
    
    static testMethod void validate_getMktData() {
        
        test.startTest();
        
        Business_Plan__c plan1 = [select Id,Name from Business_Plan__c where name='Test Plan'];
        
        ApexPages.currentpage().getparameters().put('bpid' , plan1.Id);
        ApexPages.currentpage().getparameters().put('productgroup','Knees');
        
       	ChartController cc = new ChartController();
       	cc.getMktData();
        
        test.stopTest();
        
    }
    
    static testMethod void validate_getSales() {
        
        test.startTest();
        
        Business_Plan__c plan1 = [select Id,Name from Business_Plan__c where name='Test Plan'];
        
        ApexPages.currentpage().getparameters().put('bpid' , plan1.Id);
        ApexPages.currentpage().getparameters().put('productgroup','Knees');
        
       	ChartController cc = new ChartController();
       	cc.getSales();
        
        test.stopTest();
        
    }
    
}