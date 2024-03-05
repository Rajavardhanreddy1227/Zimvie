/****************************************************/
// @Auther: Ankit Dave
// @Version: 2.0
// @Date: 12/10/2015
// @Class: ReSchedular
/****************************************************/
trigger OpportunityReScheduling on Opportunity (after update, before update, after insert) 
{
  list<Opportunity> oppinsert = new list<Opportunity>();
    list<Opportunity> oppupdate = new list<Opportunity>();
    
    for (Opportunity o: Trigger.new){
        if(o.CloseDate != null && Trigger.Isupdate && o.CloseDate != Trigger.OldMap.get(o.Id).CloseDate){
            system.debug('inside update');
            oppupdate.add(o);
        }
    }
    if(oppupdate.size()>0){
        ReSchedular.ScheduleDateUpdate(oppupdate);
    }
}