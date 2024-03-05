/**
* @author Appirio Inc.
* @date Feb, 2020
*
* @group UserTerritory2Association
*
* @description Encapsulates all behaviour logic relating to the UserTerritory2Association object
*       For more guidelines and details see
*    https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Domain_Layer
*/
trigger UserTerritory2Associations on UserTerritory2Association (after insert, after update, after delete) {
  if(!Ortho_TriggerSettings.isTriggerDisabled('UserTerritory2Associations')){
    switch on Trigger.operationType{
      when AFTER_INSERT {
        Ortho_UserTerritory2Associations.onAfterInsert(Trigger.new);
      }
      when AFTER_DELETE{
        Ortho_UserTerritory2Associations.onAfterDelete(Trigger.old);
      }
      when AFTER_UPDATE{
        Ortho_UserTerritory2Associations.onAfterUpdate(Trigger.new, Trigger.oldMap);
      }
    }
  }
}