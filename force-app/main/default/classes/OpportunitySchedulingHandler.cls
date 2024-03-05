/****************************************************/
// @Auther: Ankit Dave
// @Version: 1.0
// @Date: 07/21/2015
// @Trigger: OpportunityReScheduling
/****************************************************/

public with sharing class OpportunitySchedulingHandler {

     //Update LineItemSchedule dates for all scheduling dates

	public static void ScheduleDateUpdate(String oppid, Integer day, Integer month, Integer year, Integer DayDiff) 
    {
       List<OpportunityLineItem> idval = [SELECT id FROM OpportunityLineItem WHERE OpportunityId=:oppid];
       List<OpportunityLineItemSchedule> datelist = new List<OpportunityLineItemSchedule>();
       for (Integer i = 0; i < idval.size(); i++)
       {
       	   datelist = [SELECT ScheduleDate FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId =:idval[i].id];
           for (Integer k = 0; k < datelist.size(); k++)
           {
               if(DayDiff <> 0)
               {
               	//automatic functionality actually adds 24 list (12 for quantity 12 for revenue)
               	//editing schedule for quantity
               	if(k<12)
               	{
               		Date mydate = date.newInstance(year,month,day);
                	datelist[k].ScheduleDate = mydate.addmonths(k);
                }
               	//editing schedule for revenue
               	else
               	{
               		Date mydate = date.newInstance(year,month,day);
                	datelist[k].ScheduleDate = mydate.addmonths(k-12);
                }
               }
            }
           if(!datelist.isEmpty())
           {
           		update datelist;
           }
    	}
    }    

      //Update ServiceDate with closeDate

    public static void ScheduleServiceDateUpdate(String oppid)
    {
    	List<Opportunity> oliList = [SELECT Id, Name, CloseDate, RecordTypeID, (SELECT Id, ServiceDate, OpportunityId from OpportunityLineItems) from Opportunity where Id =:oppid];
    	List<OpportunityLineItem> oliUpdateList = new List<OpportunityLineItem>();
    	for(Opportunity x : oliList)
    	{
        	for(OpportunityLineItem oli : x.OpportunityLineItems)
        	
	        {
	        	oli.ServiceDate = x.CloseDate;
		        oliUpdateList.add(oli);
		    }
        }
      	
      	if(!oliUpdateList.isEmpty()) 
      	{
        	update oliUpdateList;
      	}
   	}
}