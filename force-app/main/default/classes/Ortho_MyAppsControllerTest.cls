/**
* @author Appirio Inc.
* @date March, 2020
*
* @group Opportunity
*
* @description Test Class for Ortho_ListviewSelector Controller
*/
@isTest
public class Ortho_MyAppsControllerTest {
    
    @testSetup
    public static void createTestData(){
        User appUser = TestUtilsLocal.createTestUser('appUser',true);
        system.assertNotEquals(null, appUser.id);
        
        //get App details
        AppMenuItem objAppMenuItem = [SELECT Id, Name, Label FROM AppMenuItem Limit 1];
        // Add custom setting
        Ortho_App_Favorites__c objApp= new Ortho_App_Favorites__c(Name ='CustomSetting',User_Id__c = appUser.id,Is_Favorite__c = true,App_Id__c = objAppMenuItem.id);
        insert objApp;
        
    }
    
    @istest
    static void testUserApp(){
        User appUser = [Select Id from User where name='appUser'];
        AppMenuItem objAppMenuItem = [SELECT Id, Name, Label FROM AppMenuItem Limit 1];
        Test.startTest();
        //Run as User
        System.runAs(appUser) {
            Ortho_MyAppsController.getApps();
            Ortho_MyAppsController.setFavorite(objAppMenuItem.id,objAppMenuItem.Name,true);
        }
        Ortho_MyAppsController.OrthoApps omac = new Ortho_MyAppsController.OrthoApps();
        omac.addFavorite(objAppMenuItem);
        Ortho_MyAppsController.setFavorite(objAppMenuItem.id,objAppMenuItem.Name,true);
        Test.stopTest();
    }
    
}