//*******************************************************************************************************************************//
// Discription: CampaignMember trigger to copy Segment Details from Campaign to Lead  
// Developer : Hardeep Brar
// Version   : 1.0
// Object     : Campaign Member
// Class     :  SegmentUpdateOnLeadData
//*******************************************************************************************************************************//

trigger SegmentUpdateOnLead on CampaignMember (after insert) {

SegmentUpdateOnLeadData.campaignMemberData(Trigger.new);

}