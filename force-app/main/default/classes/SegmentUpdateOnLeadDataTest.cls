//***************************//
        // Developer  : Hardeep Brar
        // Version    : 1.0
        // Object     : Account
        // Class      : SegmentUpdateOnLeadData     
        //  Trigger   : SegmentUpdateOnLead
        //***************************//

@isTest (seeAllData=false)
private class SegmentUpdateOnLeadDataTest{

            private static testmethod void basic()
            {
            
                
               Test.startTest(); 
               
               Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Cvent Leads').getRecordTypeId();
               Id campaignRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Cvent Campaign').getRecordTypeId();
               
               
               Lead l = new Lead(lastname='11', company='11', RecordTypeId=leadRecordTypeId);
               insert l;
                    
                Campaign testCampaign= new Campaign(Name= 'TestCampaign', Segment__c = 'Dental',City__c='Warsaw',State__c= 'Nevada', Country__c='United States',RecordTypeId=campaignRecordTypeId);
                insert testCampaign;
                    
               CampaignMember mem = new CampaignMember (campaignid=testCampaign.id, leadid=l.id);
               insert mem;
                    
               
               System.debug('Created new Campaign Member');
                
               Test.stoptest();
        
            }
}