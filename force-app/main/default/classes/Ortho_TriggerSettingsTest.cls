@isTest
public class Ortho_TriggerSettingsTest {   
    @isTest
    public static void isTriggerDisabledTest()
    {
       Ortho_Mobile_Setting__mdt[] triggerSetting = [SELECT MasterLabel, Value__c, Setting_Type__c 
                                                      FROM Ortho_Mobile_Setting__mdt WHERE
                                                      Test_Context__c = True];
        
        
        String triggerName =  'Test Trigger All';
        Ortho_TriggerSettings.isTriggerDisabled(triggerName);
        
        triggerName =  'Test Trigger Profile';
        Ortho_TriggerSettings.isTriggerDisabled(triggerName);
        
        triggerName =  'Test Trigger User';
        Ortho_TriggerSettings.isTriggerDisabled(triggerName);
    }   
    
}