@isTest
public class AssignmentRulesonCaseTriggerTest 
{
    @isTest static void insertCaseTestMethod() 
    {
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Deal Support Request').getRecordTypeId();
        
        Case cs = new Case();
        cs.Request_Type__c = 'Capital Solutions Team';
        cs.Status = 'New';
        cs.Origin = 'Phone';
        cs.Subject = 'Test Case';
        cs.Description = 'test';
        cs.RecordTypeId = caseRecordTypeId;
        
        insert cs;
        
        System.assertNotEquals(null, cs.Id);
    }
}