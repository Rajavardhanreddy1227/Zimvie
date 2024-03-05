@isTest
public class BusinessPlanCreation_Test {
    
    public static Account acc;
    public static Opportunity newOpp1;
    public static Opportunity newOpp2;
    
    @testSetup static void setup() {
        
        list<Business_Plan_Settings__c> insert_BPSetting = new list<Business_Plan_Settings__c>();
        
        Business_Plan_Settings__c bpSetting = new Business_Plan_Settings__c();
        bpSetting.Name = 'Product Group - 01';
        bpSetting.Pricing_Impact__c = -2.9;
        bpSetting.Product_Group__c = 'Knees';
        insert_BPSetting.add(bpSetting);
        
        Business_Plan_Settings__c bpSetting01 = new Business_Plan_Settings__c();
        bpSetting01.Name = 'Headcount Summary - 01';
        bpSetting01.Product_Group__c = 'B.E.S.T';
        insert_BPSetting.add(bpSetting01);
        
        insert insert_BPSetting;
        
        Trigger_Settings__c cs = new Trigger_Settings__c();
        cs.Name = 'AddUsersToPSQueues Trigger';
        cs.Active__c = false;
        insert cs;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User u = new User(Alias = 'stand', Email='AVPuser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='AVPuser@testorg.com');
        insert u;
        
        RecordType rt = [SELECT Id,Name,SobjectType FROM RecordType WHERE Name LIKE '%Healthcare Facility%']; 
        
        acc = new Account();

       // acc.RecordTypeId = '012800000002AW5AAM';//Healthcare Facility
        acc.RecordTypeId = rt.Id;
        acc.Name = 'APEX SURGICAL(FOX-GATTEN)';
        acc.RVP__c = u.Id;
        insert acc;
        
        Annual_Sales_Data__c annualSales = new Annual_Sales_Data__c();
        annualSales.Territory_Name__c = acc.Id;
        annualSales.Year__c = 2019;
        annualSales.Quarter__c= 'First';
        annualSales.Product_Group__c = 'Knees';
        annualSales.This_Year_YTD_Sales_Thru_Month__c = 15000;
        insert annualSales;
        
    }
    
    static testMethod void validate_BusinessPlanCreation() {
        
        test.startTest();
        
        Account acct = [select Id,Name from Account where Name='APEX SURGICAL(FOX-GATTEN)'];
                
        Business_Plan__c plan = new Business_Plan__c();
        plan.Name = 'Test Plan';
        plan.Active__c = TRUE;
        plan.Status__c = 'Active';
        plan.Year__c = 2019;
        plan.Quarter__c = 'First';
        plan.Territory_Account_Name__c = acct.Id;
        insert plan;
        
        system.debug('-----plan---'+plan);
        
        Executive_Summary__c exe = [select Id, Name, Business_Plan__c, IsActive__c from Executive_Summary__c];
        
        system.debug(' checking exe' +exe.Business_Plan__c);
        system.debug(' plan exe' +exe.Business_Plan__c);
        system.assertEquals(plan.Id, exe.Business_Plan__c);
        
        Product_Sales_Summary__c prodSummary= [select Id, Name,Business_Plan__c,Product_Group__c from Product_Sales_Summary__c];
        system.assertEquals(plan.Id, prodSummary.Business_Plan__c);
        system.assertEquals('Knees', prodSummary.Product_Group__c);
        
        Headcount_Summary__c hcSummary = [select Id,Name,Business_Plan__c,Specialty__c from Headcount_Summary__c];
        system.assertEquals(plan.Id, hcSummary.Business_Plan__c);
        system.assertEquals('B.E.S.T', hcSummary.Specialty__c);

        
        SubmitForApprovalGen.approvalProcessStatus(plan.Id);

        SubmitForApprovalGen.submitAndProcessApprovalRequest(plan.Id, 'Sending Plan for Approval');
            
        test.stopTest();
        
    }

}