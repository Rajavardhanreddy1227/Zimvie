@isTest
public class BusinessPlanSalesSummaryController_Test {
    
    public static Account acc;
    public static Opportunity newOpp1;
    public static Opportunity newOpp2;
    public static User u;
    
    @testSetup static void setup() {
        
        Trigger_Settings__c cs = new Trigger_Settings__c();
        cs.Name = 'AddUsersToPSQueues Trigger';
        cs.Active__c = false;
        insert cs;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        UserRole role = new UserRole(Name = 'AVP-User');
        //insert role;
        
        User u = new User(Alias = 'stand', Email='AVPuser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,UserRoleId=role.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='AVPuser@testorg.com');
        //insert u;
		RecordType rt = [SELECT Id,Name,SobjectType FROM RecordType WHERE Name LIKE '%Healthcare Facility%']; 
        
        acc = new Account();

       // acc.RecordTypeId = '012800000002AW5AAM';//Healthcare Facility
        acc.RecordTypeId = rt.Id;
        acc.Name = 'APEX SURGICAL(FOX-GATTEN)';
        acc.RVP__c = u.Id;
        insert acc;
        
        Business_Plan__c plan = new Business_Plan__c();
        plan.Name = 'Test Plan';
        plan.Active__c = TRUE;
        plan.Status__c = 'Active';
        plan.Year__c = 2019;
        plan.Quarter__c = 'Second';
        plan.Territory_Account_Name__c = acc.Id;
        insert plan;
        
        Annual_Sales_Data__c annualSales = new Annual_Sales_Data__c();
        annualSales.Territory_Name__c = acc.Id;
        annualSales.Year__c = 2020;
        annualSales.This_Year_YTD_Sales_Thru_Month__c = 15000;
        insert annualSales;
        
        Product_Sales_Summary__c pSummary = new Product_Sales_Summary__c();
        pSummary.Name = 'Test Knees Sales Summary';
        pSummary.Business_Plan__c = plan.Id;
        pSummary.Product_Group__c = 'Knees';
        pSummary.This_Quarter_Projection__c = 10000;
        pSummary.Pricing_Impact__c = 10;
        pSummary.Opportunities__c = 7500;
        pSummary.Risks__c = 1000;
        insert pSummary;
        
        //Planned_Growth__c = Sales_Plan__c - Full_Year_Estimate__c
        //Sales_Plan__c = Full_Year_Estimate__c + (Full_Year_Estimate__c * Pricing_Impact__c ) + Opportunities__c + Risks__c
        //Full_Year_Estimate__c = Annual_Sales_Data__r.This_Year_YTD_Sales_Thru_Month__c + This_Quarter_Projection__c
        
        Product_Sales_Summary__c pSummary2 = new Product_Sales_Summary__c();
        pSummary2.Name = 'Test Hips Sales Summary';
        pSummary2.Business_Plan__c = plan.Id;
        pSummary2.Product_Group__c = 'Hips';
        pSummary.This_Quarter_Projection__c = 14000;
        pSummary.Pricing_Impact__c = 14;
        pSummary.Opportunities__c = 9500;
        pSummary.Risks__c = 3000;
        insert pSummary2;
        
    }    
    
    static testMethod void validate_ForAVPUser() {
        
        test.startTest();
        
        Business_Plan__c plan1 = [select Id,Name from Business_Plan__c where name='Test Plan'];
        
        system.debug('Check plan1:' +plan1);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        UserRole role = new UserRole(Name = 'AVP-User');
        insert role;
        
        User u = new User(Alias = 'stand', Email='AVPuser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,UserRoleId=role.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='AVPuser@testorg.com');
        insert u;
                
        System.runAs(u) {
            
        	BusinessPlanSalesSummaryController.getSalesSummary(plan1.Id);
        }
        
        test.stopTest();
        
    }
    
    static testMethod void validate_ForNonAvpUsers() {
        
        test.startTest();
        
        Business_Plan__c plan2 = [select Id,Name from Business_Plan__c where name='Test Plan'];
        
        system.debug('Check plan2' +plan2);
       
        //BusinessPlanSalesSummaryController.getSalesSummary(plan2.Id);
        
        test.stopTest();
        
    }
    
}