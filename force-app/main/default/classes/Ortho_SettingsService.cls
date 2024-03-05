/**
 * @author Appirio
 * @date Feb, 2020
 *
 * @description Contains methods to return records of Ortho Metadata Records based on requirement.
 */


public with sharing class Ortho_SettingsService {
    
    /**
    * @description Returns ortho mobile settings by type.
    */


    public static List<Ortho_Mobile_Setting__mdt> getSettingByType(String type){
        if(Test.isRunningTest()){
             Ortho_Mobile_Setting__mdt[] orthoMobileSettings = [SELECT MasterLabel, QualifiedApiName, Setting_Type__c ,Value__c, Trigger_Name__c, Trigger_Context__c, Trigger_Disabled__c FROM Ortho_Mobile_Setting__mdt where Setting_Type__c = :type
                                                          AND Test_Context__c = True];
        	return orthoMobileSettings;
        }
        
        Ortho_Mobile_Setting__mdt[] orthoMobileSettings = [SELECT MasterLabel, QualifiedApiName, Setting_Type__c ,Value__c, Trigger_Name__c, Trigger_Context__c, Trigger_Disabled__c FROM Ortho_Mobile_Setting__mdt where Setting_Type__c = :type
                                                          AND Test_Context__c = False];
        return orthoMobileSettings;
    }
    
    /**
    * @description Returns all the app favorites by user.
    */

    public static List<Ortho_App_Favorites__c> getAppFavoritesByUser(Id userId){
        List<Ortho_App_Favorites__c> appFavorites = [Select id, App_Id__c, User_Id__c,Is_Favorite__c from Ortho_App_Favorites__c where User_Id__c =: userId and Is_Favorite__c = true];
        return appFavorites;
    }
    
    /**
    * @description Returns all the app favorites by user and app.
    */
    
    public static List<Ortho_App_Favorites__c> getAppFavoritesByUserAndApp(Id userId, String appId){
        List<Ortho_App_Favorites__c> appFavorites = [Select id, App_Id__c, User_Id__c,Is_Favorite__c from Ortho_App_Favorites__c where User_Id__c =: userId and App_Id__c =: appId];
        return appFavorites;
    }
    
    
    /**
    * @description Returns all the general Settings metadata values by Name
    */
    public static String getGeneralSettingValueByName(String settingName){
        Ortho_Sales_General_Setting__mdt[] orthoSalesGeneralSettings = [SELECT MasterLabel, Value__c FROM
            Ortho_Sales_General_Setting__mdt WHERE DeveloperName = :settingName];
        String value = '';
        if(!orthoSalesGeneralSettings.isEmpty()){
            value = orthoSalesGeneralSettings[0].Value__c;
        }
        return value;
    }
    
     /**
    * @description Returns all the general Settings metadata values by Type
    */
    
    public static Map<String,String> getGeneralSettingValueByType(String typeName){
        Map<String,String> oppRecordTypeMapByProduct = new Map<String,String>();
        Ortho_Sales_General_Setting__mdt[] orthoSalesGeneralSettings = [SELECT MasterLabel, Value__c FROM
                                                                        Ortho_Sales_General_Setting__mdt WHERE Type__c = :typeName];


        String recTypeid;

        for(Ortho_Sales_General_Setting__mdt os: orthoSalesGeneralSettings){
            if(typeName == Ortho_Constants.PRODUCT_ROLE_MAPPING){
                recTypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(os.MasterLabel).getRecordTypeId();
                oppRecordTypeMapByProduct.put(recTypeid, os.Value__c);
            }else{
                oppRecordTypeMapByProduct.put(os.MasterLabel, os.Value__c);
            }
        }


        return oppRecordTypeMapByProduct;
       
        
    }

}