/**   
*     iPadContentViewsBatch
*    
*     author:  Shuji Iida
*     date:    Jan 4 2011
*     version: 1.0 
*     
*     speccification:  Defect 2436099 - Content View Counter is not updating if a user has read-only access to the content record
*     author:          Tom G 
*     date:             Jan 4 2011
*     version:          1.0
* 
*     Description: 
*     create a Scheduled Batch Apex job that runs every night at 1:00AM 
*     that reads through each record on the custom object, 
*      and updates the Content records with those values. 
*      These iPad_Content_Views__c records should then be deleted.
**/

global class iPadContentViewsBatch  implements Database.Batchable<sObject>,Database.Stateful
{
    
 
  global final String Query;
   
   global iPadContentViewsBatch(String q){
          Query = q;
   } 

   global Database.QueryLocator start(Database.BatchableContext BC){
   
      return Database.getQueryLocator(Query);
       
   }
  
   global void execute(Database.BatchableContext BC, List<iPad_Content_Views__c> ipadContViewsList)
   {
   /*
         Set<Id> contentIdSet = new Set<Id>(); 
         
         for(iPad_Content_Views__c ipadCon: ipadContViewsList){
            if(ipadCon.ContentId__c!=null){
                contentIdSet.add(ipadCon.ContentId__c);
            }
         } 
         
     List<ContentVersion> contentVersions = [select Id, iPad_Content_Views__c from ContentVersion where Id in :contentIdSet];
     Map<String,ContentVersion> mapOfContentVersions = new Map<String,ContentVersion>();
     for (ContentVersion cv : contentVersions){
         mapOfContentVersions.put(cv.Id,cv);
     }
     
     for(iPad_Content_Views__c ipadConViews: ipadContViewsList){
            ContentVersion conV = mapOfContentVersions.get(ipadConViews.ContentId__c);
            if(conV.iPad_Content_Views__c==null){
               conV.iPad_Content_Views__c=0;
            }
            conV.iPad_Content_Views__c += ipadConViews.howMuch__c;
     }
     List<ContentVersion> listOfContentVersion = mapOfContentVersions.values();
     if(listOfContentVersion.size()>0){
         System.Debug('iPadContentViewsBatch:listOfContentVersion.size()='+listOfContentVersion.size()+'-------------');
         update listOfContentVersion;
     }
      for(iPad_Content_Views__c ipv: ipadContViewsList){
        ipv.howMuch__c=0;
      }
      if(ipadContViewsList.size()>0){
         System.Debug('iPadContentViewsBatch:ipadContViewsList.size()='+ipadContViewsList.size()+'-------------');
         update ipadContViewsList;
      }
    */
    }

   global void finish(Database.BatchableContext BC){
   
   
   }

}