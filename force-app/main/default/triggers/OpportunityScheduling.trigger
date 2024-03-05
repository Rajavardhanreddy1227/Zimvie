trigger OpportunityScheduling on Opportunity (before insert, after update) {
  
  if(!Validator_cls.hasAlreadyDone()){
       // Your trigger code here
     
  List<OpportunityLineItem> opplineitems =  [select Id, OpportunityId,Quantity ,HasSchedule ,HasRevenueSchedule,HasQuantitySchedule,TotalPrice, (Select id,Revenue,ScheduleDate,OpportunityLineItemId from OpportunityLineItemSchedules) from OpportunityLineItem where OpportunityId IN: Trigger.New];  
  System.debug('Check1');  
  Map<ID,List<OpportunityLineItem>> map_OppID_LineItem = new Map<ID,List<OpportunityLineItem>>();  
    
  List<OpportunityLineItem > tempopplineitems = new List<OpportunityLineItem>();
  System.debug('Check2');    
      for(OpportunityLineItem o : opplineitems)  
            {  
                if(map_OppID_LineItem.containsKey(o.OpportunityID))   
                    {  
                        tempopplineitems = map_OppID_LineItem.get(o.OpportunityID);  
                        tempopplineitems.add(o);  
                        map_OppID_LineItem.put(o.OpportunityID , tempopplineitems);   
                    }  
                else   
                    {  
                        tempopplineitems = new List<OpportunityLineItem>();  
                        tempopplineitems.add(o);  
                        map_OppID_LineItem.put(o.OpportunityID , tempopplineitems);  
                    }  
            }  
 System.debug('Check3');
 List<OpportunityLineItemSchedule> newScheduleObjects = new List<OpportunityLineItemSchedule>();
 List<OpportunityLineItemSchedule> listOppTBU = new List<OpportunityLineItemSchedule>();  
     for(Opportunity opp : Trigger.New)  
            {
             System.debug('Check4');
               //System.debug(Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('RecordTypeLabel').getRecordTypeId());
              if(opp.Id!= null)
              {if(opp.RECORDTYPEID != '012C0000000QFqY')
              {              
                //check opportunity has list of lineitems in map  
                System.debug('Check4');
                if(map_OppID_LineItem.containsKey(opp.id))   
                    {  
                      Date d = (opp.closeDate);
                      
                      System.debug('Check5');
                       //Loop over the list of lineitems  
                       for(OpportunityLineItem o : map_OppID_LineItem.get(opp.id))  
                          {  
                              System.debug('Check6');
                                System.debug('o.HasQuantitySchedule='+o.HasQuantitySchedule);
                                System.debug('o.HasRevenueSchedule='+o.HasRevenueSchedule);
                                if(o.HasQuantitySchedule==true && o.HasRevenueSchedule==true)
                                  {
                                 // List<OpportunityLineItemSchedule> l = [Select id,Revenue,ScheduleDate,OpportunityLineItemId    from OpportunityLineItemSchedule where OpportunityLineItemId =: o.id ];
                                  for(OpportunityLineItemSchedule x : o.OpportunityLineItemSchedules)
                                  {
                                    listOppTBU.add(x);
                                  }
                                  System.debug('Inside Else');   
                                  for (Integer i = 0;i < 12;i++) {
                                  OpportunityLineItemSchedule s = new OpportunityLineItemSchedule();
                                   system.debug('Opp' + o.TotalPrice);
                                  s.Revenue = o.TotalPrice/12;
                                  s.Quantity = o.Quantity/12;
                                  s.ScheduleDate = d.addmonths(i);
                                  s.OpportunityLineItemId = o.id;
                                  s.Type = 'both'; 
                                  newScheduleObjects.add(s);
                                }
                                }
                              }
                          }
                         System.debug('Check7'); 
                    }}
                    System.debug('Check8');
              }
                      
              
            System.debug('YoYo');
            Validator_cls.setAlreadyDone();
            delete listOppTBU;            
            if(newScheduleObjects.size()>0)
            {
                insert newScheduleObjects;
            }
            
   }
}