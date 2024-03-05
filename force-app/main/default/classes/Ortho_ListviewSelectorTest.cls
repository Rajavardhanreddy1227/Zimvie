/**
* @author Appirio Inc.
* @date March, 2020
*
* @group Opportunity
*
* @description Test Class for Ortho_ListviewSelector Controller
*/
@isTest
public class Ortho_ListviewSelectorTest {
    
    @testSetup
    public static void createTestData(){
        User appUser = TestUtilsLocal.createTestUser('appUser',true);
    }
    
    @istest
    static void testListView(){
        User appUser = [Select Id from User where name='appUser'];
        Set<Schema.SObjectType> setObject = new Set<Schema.SObjectType>{Account.sObjectType};
        Test.startTest();
        System.runAs(appUser) {
            Ortho_ListviewSources objOrtho = new Ortho_ListviewSources();
            ObjOrtho.getValues();
            ObjOrtho.getDefaultValue();
        }
        Test.stopTest();
    }
}