/**
* @author Appirio Inc.
* @date March, 2020
*
* @group Opportunity
*
* @description Test Class for Ortho_ChartDataYOYTable Controller
*/
@isTest
public class Ortho_ChartDataYOYTableTest {
    
    @testSetup
    public static void createTestData(){
        TestUtilsLocal.createCustomSetting('AddUsersToPSQueues Trigger',true);
        Ortho_KPI__c objKPI = new Ortho_KPI__c();
        objKPI.KPI_Type__c='Year-Over-Year';
        objKPI.Timeframe__c='Yearly';
        //objKPI.OwnerId = appUser.id;
        objKPI.KPI_Current__c = 12000.00;
        objKPI.KPI_Previous__c = 1000.00;
        objKpi.KPI_Target__c = 12.00;
        insert objKPI;
    }
    
    @istest
    static void testDataYOYTable(){
        Ortho_KPI__c objKPI = [Select Id,OwnerId from Ortho_KPI__c LIMIT 1];
        User appUser = TestUtilsLocal.createTestSalesUser('appUser',true);
        Test.startTest();
        System.runAs(appUser) {
            objKPI.OwnerId = appUser.id;
            update objKPI;
            System.assertEquals(appUser.id, objKPI.OwnerId);
            Ortho_ChartDataYOYTable objOrtho = new Ortho_ChartDataYOYTable();
            objOrtho.getName();
            objOrtho.getData();
        }
        Test.stopTest();
    }
}