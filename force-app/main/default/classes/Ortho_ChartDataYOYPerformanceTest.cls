/**
* @author Appirio Inc.
* @date March, 2020
*
* @group Opportunity
*
* @description Test Class for Ortho_ChartDataYOYPerformance Controller
*/
@isTest
public class Ortho_ChartDataYOYPerformanceTest {
    
    @testSetup
    public static void createTestData(){
        TestUtilsLocal.createCustomSetting('AddUsersToPSQueues Trigger',true);
        Product2 objProduct = TestUtilsLocal.createProduct();
        Ortho_KPI__c objKPI = new Ortho_KPI__c();
        objKPI.KPI_Type__c='Year-Over-Year';
        objKPI.Timeframe__c='Yearly';
        objKPI.Product__c = objProduct.id;
        objKPI.KPI_Current__c = 12000.00;
        objKPI.KPI_Previous__c = 1000.00;
        objKPI.KPI_Label__c = 'KPI_Label__c';
        insert objKPI;
    }
    @istest
    static void testDataYOYPerf(){
        Ortho_KPI__c objKPI = [Select Id,OwnerId from Ortho_KPI__c LIMIT 1];
        User appUser = TestUtilsLocal.createTestSalesUser('appUser',true);
        Ortho_ChartFilter [] filters=new List<Ortho_ChartFilter>{
            new Ortho_ChartFilter('Product__c', 'Product', new List<String>{
                'All'})
                };
               Test.startTest();
        System.runAs(appUser) {
            objKPI.OwnerId = appUser.id;
            update objKPI;
            System.assertEquals(appUser.id, objKPI.OwnerId);
            Ortho_ChartDataYOYPerformance objOrtho = new Ortho_ChartDataYOYPerformance();
            objOrtho.getName();
            objOrtho.getData();
            objOrtho.getData(filters);
        }
        Test.stopTest();
    }
}