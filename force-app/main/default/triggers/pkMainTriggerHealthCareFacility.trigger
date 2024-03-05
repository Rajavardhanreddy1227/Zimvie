/**
 * @description       : 
 * @author            : hhernandez@pkglobal.com
 * @group             : 
 * @last modified on  : 12-02-2021
 * @last modified by  : hugodhm@icloud.com
**/
trigger pkMainTriggerHealthCareFacility on Healthcare_Surgeon_Relationship__c (before insert,before update ) {

    if (trigger.isBefore ) {
        try{

            for (Healthcare_Surgeon_Relationship__c hdr : Trigger.new) {
                hdr.identifier__c = hdr.Surgeon__c+'-'+hdr.Healthcare_Facility__c+'-'+hdr.Location_Type__c;    
            }

            
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }

}