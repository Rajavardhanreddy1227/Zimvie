//****************************************************************************************************************//
    // Trigger name: OpportunityScorecard
    // Author: Prateekshit Malhotra
    // Date of last modification: 08/29/2012
    // Purpose of this trigger: Sums the Product scores of products related to respective opportunity
    //****************************************************************************************************************//


trigger OpportunityScorecard on Opportunity (before insert, before update) {
    List<OpportunityLineItem> opplineitems =  [select OpportunityId, Product_Score__c from OpportunityLineItem where OpportunityId IN: Trigger.New];    
    Map<ID,List<OpportunityLineItem>> map_OppID_LineItem = new Map<ID,List<OpportunityLineItem>>(); 
    
    List<OpportunityLineItem > tempopplineitems = new List<OpportunityLineItem>();
        
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
        
        
        List<Opportunity> listOppTBU = new List<Opportunity>();  
        for(Opportunity opp : Trigger.New)  
            {  
                if(opp.Id!= null){
                //check opportunity has list of lineitems in map  
                if(map_OppID_LineItem.containsKey(opp.id))   
                    {  
                        opp.Total_Product_Score__c = 0.0;
                       //Loop over the list of lineitems  
                       for(OpportunityLineItem o : map_OppID_LineItem.get(opp.id))  
                          {  
                             System.debug('Opp is = ' + opp.id);
                              System.debug('Opplineitem is = ' + o.id);
                              System.debug('o.Product_Score__c = ' + o.Product_Score__c);
                               System.debug('opp.Total_Product_Score__c = ' + opp.Total_Product_Score__c);
                             opp.Total_Product_Score__c =  opp.Total_Product_Score__c + o.Product_Score__c;
                             listOppTBU.add(opp);   
                          }
                          
                    }
                }
                      
            }  
        
    }