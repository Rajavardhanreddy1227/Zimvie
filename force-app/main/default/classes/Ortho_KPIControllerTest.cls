/**
* @author Appirio Inc.
* @date March, 2020
*
* @description Test Class for Ortho_KPI Controller
*/
@isTest
public class Ortho_KPIControllerTest {
    @testSetup
    public static void CreateCustomSetting(){
        
        TestUtilsLocal.createCustomSetting('AddUsersToPSQueues Trigger',true);
    }
    public Static Ortho_KPI__c CreateTestData(User usr){
        
        system.runAs(usr){
            //Create Ortho KPI 
            Ortho_KPI__c oKPI = new Ortho_KPI__c(KPI_Type__c = 'Target',
                                                 Timeframe__c = 'Monthly',
                                                 Product__c = 'F&A',
                                                 KPI_Current__c = 63000,
                                                 KPI_Previous__c = 56700,
                                                 KPI_Label__c = '2020-07');
            INSERT oKPI;
        }
        Ortho_KPI__c oKPI = [SELECT Id, KPI_Current__c, KPI_Previous__c, KPI_Target__c, KPI_Type__c, LastModifiedById, 
                             Name, OwnerId, Product__c, Timeframe__c, 
                             KPI_Label__c FROM Ortho_KPI__c WHERE Product__c = 'F&A'];
        return oKPI;
    }
    //Check when Time Frame is Monthly
    @isTest
    public Static void MonthlyTimeFrame()
    {
        //Create Test User
        User usr = TestUtilsLocal.createTestUser('Test@2', True); 
        Test.startTest();
        System.runAs(usr){
            Ortho_KPI__c oKPI = CreateTestData(usr);
            System.assertNotEquals(oKPI, NULL);
            Ortho_KPIController.getProductData(oKPI.Product__c);
            Test.stopTest();
        }
    }
    
    //Check When Time Frame is Quarterly
    @isTest
    public static void QuarterlyTimeFrame()
    {
        //Create Test User
        User usr = TestUtilsLocal.createTestUser('Test@2', True); 
        Test.startTest();
        System.runAs(usr){
            Ortho_KPI__c oKPI = CreateTestData(usr);            
            System.assertNotEquals(oKPI, NULL);
            oKPI.Timeframe__c = 'Quarterly';
            UPDATE oKPI;
            Ortho_KPIController.getProductData(oKPI.Product__c);
            Test.stopTest();
        }
    }
    
}