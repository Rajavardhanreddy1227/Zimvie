/**
* @author Appirio Inc.
* @date Feb, 2020
* @group Opportunity
* @description Trigger on opportunity to populate and validate some fields.
*/

trigger Opportunities on Opportunity (after update, before update, before insert, after insert) {
    if(!Ortho_TriggerSettings.isTriggerDisabled('Opportunities')){
        List<Opportunity> filteredOppList = OpportunityService.filterOpportunities(
            Trigger.new, 'RecordTypeId',
            Ortho_Util.getUSOrthoOpptyRecordTypes().keySet());

        switch on Trigger.operationType{
            when AFTER_INSERT {
                Ortho_Opportunities.onAfterInsert(filteredOppList);
            }
            when AFTER_UPDATE{
                Ortho_Opportunities.onAfterUpdate(filteredOppList, Trigger.oldMap);
            }
            when BEFORE_INSERT{
                Ortho_Opportunities.onBeforeInsert(filteredOppList);
            }
            when BEFORE_UPDATE{
                Ortho_Opportunities.onBeforeUpdate(filteredOppList,  Trigger.oldMap);
            }
        }
    }

}