@isTest
public class BusinessPlanAVPViewController_Test {
    
    public static Account acc;
    public static Opportunity newOpp1;
    public static Opportunity newOpp2;
    
    @testSetup static void setup() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        userRole uR = [Select id, name from userRole where name='Consumer Acct Owner'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId= uR.id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standardusertest1234@testorg.com');
        insert u;
        RecordType rt = [SELECT Id,Name,SobjectType FROM RecordType WHERE Name LIKE '%Healthcare Facility%'];
        
        system.runAs(u){
            territory__c tr = new territory__c(Name='test');
            insert tr;
        acc = new Account();
       // acc.RecordTypeId = '012800000002AW5AAM';//Healthcare Facility
        acc.RecordTypeId = rt.Id;
        acc.Name = 'APEX SURGICAL(FOX-GATTEN)';
        acc.RVP__c = u.Id;
        acc.territory__c=tr.id;
        insert acc;
            
        
        Business_Plan__c plan = new Business_Plan__c();
        plan.Name = 'Test Plan';
        plan.Active__c = TRUE;
        plan.Status__c = 'Active';
        plan.Year__c = 2022;
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
    }
    
    static testMethod void validate_BusinessPlanAVPView() {
        
        test.startTest();
        
        Account acct = [select Id,Name from account where Name=:'APEX SURGICAL(FOX-GATTEN)'];
        
        Business_Plan__c bPlan = [select Id, Name, Active__c, Year__c from Business_Plan__c];
        user u=[Select id from user limit 1];
        
        Product_Sales_Summary__c pKneesSales = [Select Id, Name from Product_Sales_Summary__c where Name=:'Test Knees Sales Summary'];
        Product_Sales_Summary__c pHipsSales = [Select Id, Name from Product_Sales_Summary__c where Name=:'Test Hips Sales Summary'];
        
        system.runAs(u){
        BusinessPlanAVPViewController bPController = new BusinessPlanAVPViewController();
       BusinessPlanAVPViewController.getAllBusinessPlans();
        BusinessPlanAVPViewController.findDataSetForChart(bPlan.id);
        }
        //Create and Test Approvals
        //BusinessPlanApprovalController bpApprovalController = new BusinessPlanApprovalController();
        String chkExistingApproval = BusinessPlanApprovalController.approvalProcessStatus(bPlan.id);
        
        System.assertEquals(chkExistingApproval, 'failure-headcount', 'Headcount Records are Zero');

        String respForApproval = BusinessPlanApprovalController.submitAndProcessApprovalRequest(bPlan.Id, 'Test Submission for Business Plan');
        //System.assertEquals(respForApproval, 'success', 'Approval Request was submitted');
        test.stopTest();
        
    }
    
}