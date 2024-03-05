public class Ortho_TriggerSettings {
    public static Map<String, Boolean> triggerDisabledMap;
    public static Boolean isTriggerDisabled(String triggerName){

        //if the trigger disabled map hasn't been created, create it
        if(triggerDisabledMap == null){
            triggerDisabledMap = new Map<String, Boolean>();
        }

        //check if we have already ran the logic for this trigger in this context
        Boolean triggerDisabled = triggerDisabledMap.get(triggerName);
        //return if we have
        if(triggerDisabled <> null){
            return triggerDisabled;
        }
        else{ 
            triggerDisabled = false;
        }

        //get trigger settings
        List<Ortho_Mobile_Setting__mdt> triggerSettings = Ortho_SettingsService.getSettingByType('Trigger');

        //for each setting
        for(Ortho_Mobile_Setting__mdt triggerSetting : triggerSettings){
            //if we have not disabled the trigger all ready
            //and this setting is for this trigger
            //and this setting would disable the trigger 
            if(!triggerDisabled && triggerSetting.Trigger_Name__c == triggerName && triggerSetting.Trigger_Disabled__c ){

                switch on triggerSetting.Trigger_Context__c {
                    when 'User' {
                        //if disabled for this user set to true
                        triggerDisabled = triggerDisabledForUser(triggerSetting);
                    }	
                    when 'Profile' {
                        //if disabled for this profile set to true
                        triggerDisabled = triggerDisabledForProfile(triggerSetting);
                    }
                    when 'All' {
                        //if disabled for all users set to true
                        triggerDisabled = true;
                    }
                }
            }
        }

        //store the value
        triggerDisabledMap.put(triggerName, triggerDisabled);

        //return the value
        return triggerDisabled;
    }

    private static Boolean triggerDisabledForUser(Ortho_Mobile_Setting__mdt triggerSetting){
        return UserInfo.getUserId() == triggerSetting.Value__c;
    }

    private static Boolean triggerDisabledForProfile(Ortho_Mobile_Setting__mdt triggerSetting){
        return UserInfo.getProfileId() == triggerSetting.Value__c;
    }
    
}