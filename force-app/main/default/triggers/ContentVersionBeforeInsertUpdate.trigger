/**   
*     ContentVersionBeforeInsertUpdate triggers on after insert and after update events to: 
*        set Last_Modified_on_Server__c to today if iPad_Content_Views__c has not been changed.
*    
*     @author  Denise Bacher
*     @date    Jan 5 2012
*     @version 1.0 
*     
*/

trigger ContentVersionBeforeInsertUpdate on ContentVersion (before insert, before update) {
    if(Trigger.isInsert){
        ContentLastModifiedServerHelper.isInsert(Trigger.new);
    }
    else if (Trigger.isUpdate){
        ContentLastModifiedServerHelper.isUpdate(Trigger.new, Trigger.oldMap);
    }
}