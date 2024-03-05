trigger UpdateAccountInfoOnDealsDNAnalytics on Account (after insert, after update) {

  List<dental_Deal__c> Dealids = [Select id, Account__c from dental_Deal__c where Account__c  IN:Trigger.NEW];
  List<DN_Account_Sales_Analytics__c> DNids = [Select id, Account__c from DN_Account_Sales_Analytics__c where Account__c  IN:Trigger.NEW];
  Map<Id,List<dental_Deal__c>> AccDealMap = new Map<Id,List<dental_Deal__c>>();
  Map<Id,List<DN_Account_Sales_Analytics__c>> AccDNMap = new Map<Id,List<DN_Account_Sales_Analytics__c>>();
  List<dental_Deal__c> tempdeals = new List<dental_Deal__c>();
  List<DN_Account_Sales_Analytics__c> tempDN = new List<DN_Account_Sales_Analytics__c>();
  
  for(dental_Deal__c w : Dealids)  
            {  
                if(AccDealMap.containsKey(w.Account__c))   
                    {  
                        tempdeals= AccDealMap.get(w.Account__c);  
                        tempdeals.add(w);  
                        AccDealMap.put(w.Account__c, tempdeals);   
                    }  
                else   
                    {  
                        tempdeals= new List<dental_Deal__c>();  
                        tempdeals.add(w);  
                        AccDealMap.put(w.Account__c, tempdeals);  
                    }  
            } 

   for(DN_Account_Sales_Analytics__c d : DNids)  
            {  
                if(AccDNMap.containsKey(d.Account__c))   
                    {  
                        tempDN = AccDNMap.get(d.Account__c);  
                        tempDN.add(d);  
                        AccDNMap.put(d.Account__c, tempDN);   
                    }  
                else   
                    {  
                        tempDN= new List<DN_Account_Sales_Analytics__c>();  
                        tempDN.add(d);  
                        AccDNMap.put(d.Account__c, tempDN);  
                    }  
            }
            
             
  List<dental_Deal__c> listDealTBU = new List<dental_Deal__c>(); 
  List<DN_Account_Sales_Analytics__c> listDNTBU = new List<DN_Account_Sales_Analytics__c>();   

      for(Account acc : Trigger.New)
      {
          if(AccDealMap.containsKey(acc.id))
          {
              for(dental_Deal__c deal : AccDealMap.get(acc.id))
              {
                  deal.ownerid = acc.ownerid;
                  listDealTBU.add(deal);
              }
          }
          
      }
      
      
       for(Account acc : Trigger.New)
      {
          if(AccDNMap.containsKey(acc.id))
          {
              for(DN_Account_Sales_Analytics__c dn : AccDNMap.get(acc.id))
              {
                  dn.ownerid = acc.ownerid;
                  listDNTBU.add(dn);
              }
          }
          
      }
      
  upsert listDNTBU;  
  upsert listDealTBU;

}