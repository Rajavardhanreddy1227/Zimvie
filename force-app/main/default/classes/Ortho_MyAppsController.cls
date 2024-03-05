public with sharing class Ortho_MyAppsController {
    
    public class OrthoApps {
        @AuraEnabled
        public List<AppMenuItem> apps {get;set;}

        @AuraEnabled
        public List<AppMenuItem> favorites {get;set;}

        public OrthoApps(){
            apps = new List<AppMenuItem>();
            favorites = new List<AppMenuItem>();
        }

        public void addApp(AppMenuItem ami){
            apps.add(ami);
        }
        public void addFavorite(AppMenuItem ami){
            favorites.add(ami);
        }
        
    }
    @AuraEnabled(cacheable=true)
    public static OrthoApps getApps(){
        List<Ortho_Mobile_Setting__mdt> appSettings = Ortho_SettingsService.getSettingByType('App');

        Set<String> appNames = new Set<String>();
        for(Ortho_Mobile_Setting__mdt appSetting : appSettings){
            appNames.add(appSetting.Value__c);
        }

        Set<String> appFavoritesMap = new Set<String>();


        for(Ortho_App_Favorites__c appFavorite : Ortho_SettingsService.getAppFavoritesByUser(UserInfo.getUserId())){
            appFavoritesMap.add(appFavorite.App_Id__c);
        }

        OrthoApps apps = new OrthoApps();
        for(AppMenuItem ami : Ortho_AppMenuItemSelector.selectAppMenuItemsByName(appNames)){
            if(appFavoritesMap.contains(ami.Id)){
                apps.addFavorite(ami);
            }
            else{
                apps.addApp(ami);
            }
        }

        return apps;        
    }

    @AuraEnabled
    public static void setFavorite(String appId, String appName, Boolean isFavorite){
        List<Ortho_App_Favorites__c> appFavorites = Ortho_SettingsService.getAppFavoritesByUserAndApp(UserInfo.getUserId(), appId);
        Id userId = UserInfo.getUserId();
        if(appFavorites.size() > 0){
            for(Ortho_App_Favorites__c appFavorite : appFavorites){
                appFavorite.Is_Favorite__c = isFavorite;
            }
        }
        else{
            appFavorites.add(new Ortho_App_Favorites__c(
                Name = userId+appId,
                App_Id__c = appId, 
                User_Id__c = userId,
                Is_Favorite__c = isFavorite
            ));
        }

        try{
            upsert appFavorites;
        }
        catch(Exception ex){
            throw new MyAppsException(ex.getMessage());
        }

        

    }

    public class MyAppsException extends Exception {}




}