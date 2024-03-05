/**
* @author Appirio Inc.
* @date Feb, 2020
*
* @group User_Territory_Association__c
*
* @description Encapsulates all behaviour logic relating to the User_Territory_Association__c object
*       For more guidelines and details see
*    https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Domain_Layer
*/
trigger UserTerritoryAssociations on User_Territory_Association__c (before insert, before update, after update, after insert, after delete) {
    if(!Ortho_TriggerSettings.isTriggerDisabled('UserTerritoryAssociations')){
        switch on Trigger.operationType{
            when AFTER_INSERT {
                Ortho_UserTerritoryAssociations.onAfterInsert(Trigger.new);
            }
            when AFTER_DELETE{
                Ortho_UserTerritoryAssociations.onAfterDelete(Trigger.old);
            }
            when BEFORE_INSERT{
                Ortho_UserTerritoryAssociations.setDefaults(Trigger.new, Trigger.oldMap);
            }
            when BEFORE_UPDATE{
                Ortho_UserTerritoryAssociations.setDefaults(Trigger.new, Trigger.oldMap);
            }
            when AFTER_UPDATE{
                Ortho_UserTerritoryAssociations.onAfterUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }

}