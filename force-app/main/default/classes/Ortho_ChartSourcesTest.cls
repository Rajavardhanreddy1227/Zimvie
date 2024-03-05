/**
* @author Appirio Inc.
* @date March, 2020
*
* @group Opportunity
*
* @description Test Class for Ortho_ChartSources Controller
*/
@isTest
public class Ortho_ChartSourcesTest {
 @testSetup
    public static void createTestData(){
        TestUtilsLocal.createCustomSetting('AddUsersToPSQueues Trigger',true);
    }
    @istest
    static void testDataP2T(){
        User appUser = TestUtilsLocal.createTestSalesUser('appUser',true);
               Test.startTest();
        System.runAs(appUser) {
            Ortho_ChartSources objOrtho = new Ortho_ChartSources();
            objOrtho.getDefaultValue();
            objOrtho.getValues();
        }
        Test.stopTest();
    }
}