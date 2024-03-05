@isTest
public class businessPlanExecutiveSummary_Test {
    
    public static Account acc;
    
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
       
        Executive_Summary__c exeSummary = new Executive_Summary__c();
        exeSummary.Question_Type__c = 'Processes';
        exeSummary.IsActive__c = TRUE;
        exeSummary.Executive_Summary_fld__c = 'This is the executive summary.';
        exeSummary.Business_Plan__c = plan.Id;
        insert exeSummary;
    }
    
    static testMethod void validate_getActiveExecutiveSummary_1() {
        
        test.startTest();
        
        Executive_Summary__c exsummary = [select id, Question_Type__c, IsActive__c , Executive_Summary_fld__c, Business_Plan__c
                                        from Executive_Summary__c where Business_Plan__c != null and IsActive__c = true LIMIT 1];
        
        system.debug('exsummary_1---'+exsummary);
        
        Business_Plan__c plan1 = [select Id,Name from Business_Plan__c where name='Test Plan'];
        system.debug('plan1_2---'+plan1);
        
        ApexPages.currentpage().getparameters().put('id' , plan1.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(exsummary);
        businessPlanExecutiveSummary testExeSummary = new businessPlanExecutiveSummary(sc);
        testExeSummary.ExeSum = exsummary;
        test.stopTest();
        
    }
    
    static testMethod void validate_getActiveExecutiveSummary_2() {
        
        test.startTest();
        
        Business_Plan__c plan1 = [select Id,Name from Business_Plan__c where name='Test Plan'];
        
        system.debug('plan1_2---'+plan1);
        
        businessPlanExecutiveSummary.getActiveExecutiveSummary(plan1.Id);
       
        test.stopTest();
        
    }
    
}