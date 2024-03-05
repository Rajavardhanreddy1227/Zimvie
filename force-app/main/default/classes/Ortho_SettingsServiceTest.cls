@isTest
public class Ortho_SettingsServiceTest {
    
    @testSetup
    public static void createTestData(){
        User appUser = TestUtilsLocal.createTestUser('appUser',true);
        Ortho_App_Favorites__c appFav = new Ortho_App_Favorites__c(Name='Test',User_Id__c = appUser.Id, Is_Favorite__c=true);
        insert appFav;
    }
    
    @isTest
    static void getSettingByTypeTest(){
        Test.startTest();
        List<Ortho_Mobile_Setting__mdt> oms = Ortho_SettingsService.getSettingByType('Communication Group');
        Test.stopTest();
        System.assertEquals('Group: Communications Test', oms.get(0).MasterLabel);
    }
    
    @isTest
    static void getAppFavoritesByUserTest(){
        Id appUserId = [Select Id from User where name='appUser'].Id;
        Test.startTest();
        List<Ortho_App_Favorites__c> appFav = Ortho_SettingsService.getAppFavoritesByUser(appUserId);
        Test.stopTest();
        System.assertEquals(true, appFav.get(0).Is_Favorite__c);
    }
    
    @isTest
    static void getAppFavoritesByUserAndAppTest(){
        Test.startTest();
        Id appUserId = [Select Id from User where name='appUser'].Id;
        List<Ortho_App_Favorites__c> appFav = Ortho_SettingsService.getAppFavoritesByUserAndApp(appUserId,null);
        Test.stopTest();
        System.assertEquals(true, appFav.get(0).Is_Favorite__c);
    }
    
    @isTest
    static void getGeneralSettingValueByNameTest(){
        Test.startTest();
        String ogsValue= Ortho_SettingsService.getGeneralSettingValueByName('Opportunity RecordTypes');
        Test.stopTest();
        System.assertNotEquals(null, ogsValue);
    }
    
    @isTest
    static void getGeneralSettingValueByTypeTest(){
        Test.startTest();
        Map<String,String> mapRecTypeToProduct= Ortho_SettingsService.getGeneralSettingValueByType('Product Role Mapping');
        Test.stopTest();
        List<String> oppRecTypeIds = new List<String>();
        oppRecTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('US_Extremities').getRecordTypeId());
        oppRecTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('US_Foot_and_Ankle_Sales').getRecordTypeId());
        oppRecTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('US_Hip').getRecordTypeId());
        oppRecTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('US_Cement').getRecordTypeId());
        oppRecTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Revenue_Growth').getRecordTypeId());
        oppRecTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('US_Early_Intervention').getRecordTypeId());
        oppRecTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('AM_US_SM_Sales').getRecordTypeId());
        oppRecTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('US_Trauma').getRecordTypeId());
        
       
        system.assertEquals('Extremities', mapRecTypeToProduct.get(oppRecTypeIds.get(0)));
        system.assertEquals('Foot & Ankle', mapRecTypeToProduct.get(oppRecTypeIds.get(1)));
        system.assertEquals('Hips', mapRecTypeToProduct.get(oppRecTypeIds.get(2)));
        system.assertEquals('Cement', mapRecTypeToProduct.get(oppRecTypeIds.get(3)));
        system.assertEquals('Knees', mapRecTypeToProduct.get(oppRecTypeIds.get(4)));
        system.assertEquals('Early Intervention', mapRecTypeToProduct.get(oppRecTypeIds.get(5)));
        system.assertEquals('Sports Medicine', mapRecTypeToProduct.get(oppRecTypeIds.get(6)));
        system.assertEquals('Trauma', mapRecTypeToProduct.get(oppRecTypeIds.get(7)));
    }
    
}