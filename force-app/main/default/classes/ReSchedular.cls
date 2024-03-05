/****************************************************/
// @Auther: Ankit Dave
// @Version: 2.0
// @Date: 12/10/2015
// @Trigger: OpportunityReScheduling
/****************************************************/

public class ReSchedular {

    public static void ScheduleDateUpdate(list<Opportunity> opplist){
        
        list<OpportunityLineItemSchedule> oppSchdlist = new list<OpportunityLineItemSchedule>();
        list<OpportunityLineItemSchedule> updateoppSchdlist = new list<OpportunityLineItemSchedule>();
        map<Id,list<OpportunityLineItemSchedule>> oppwithoppschmap = new map<Id,list<OpportunityLineItemSchedule>>();
        
        
        oppSchdlist = [SELECT ScheduleDate,OpportunityLineItem.OpportunityId FROM OpportunityLineItemSchedule WHERE OpportunityLineItem.OpportunityId =:opplist];
        
        for(OpportunityLineItemSchedule os: oppSchdlist){		
            if(oppwithoppschmap.containsKey(os.OpportunityLineItem.OpportunityId)){
                oppwithoppschmap.get(os.OpportunityLineItem.OpportunityId).add(os);
            }
            else{
                list<OpportunityLineItemSchedule> templist = new list<OpportunityLineItemSchedule>();
                templist.add(os);
                oppwithoppschmap.put(os.OpportunityLineItem.OpportunityId,templist);
            }
        }
        
        
        integer ncount;
        integer nrecord;
        for(Opportunity opp: opplist){
            ncount = 0;
            nrecord = 0;
            if(oppwithoppschmap.containsKey(opp.Id)){
                for(OpportunityLineItemSchedule oppforos : oppwithoppschmap.get(opp.Id)){
                    if(nrecord<12){
                        oppforos.ScheduleDate = opp.CloseDate.addMonths(ncount);
                        updateoppSchdlist.add(oppforos);
                        ncount++;
                    }
                    else{
                        oppforos.ScheduleDate = opp.CloseDate.addMonths(ncount-12);
                        updateoppSchdlist.add(oppforos);
                        ncount++;
                    }
                    nrecord++;
                }
            }
        }
        if(updateoppSchdlist.size()>0)
        list<Database.SaveResult> resultolisch = Database.update(updateoppSchdlist, false);
    }  
}