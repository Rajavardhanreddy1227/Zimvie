global without sharing class iPadContentViewIncreaseBy {
/*
    webservice static String increaseViewCountBy(Id contentId, Integer howMuch)
    {
        // if contentId null and how
        if(contentId!=null && howMuch>0){
                //ContentVersion contentVersion;
                try
                {
                    //contentVersion = [SELECT Id, iPad_Content_Views__c FROM ContentVersion WHERE Id = :contentId]; 
                    List<iPad_Content_Views__c> ipadContentViewList = [Select Id, ContentId__c , howMuch__c from iPad_Content_Views__c where ContentId__c =:contentId];  
                    if(ipadContentViewList.size()>0){
                        // Need to update the field 
                        //if(ipadContentViewList[0].howMuch__c == null){
                            //ipadContentViewList[0].howMuch__c = 0;
                        //}   
                        ipadContentViewList[0].howMuch__c+= howMuch;
                        update ipadContentViewList;
                    }else
                    {   
                        iPad_Content_Views__c newIpadContentView = new iPad_Content_Views__c();
                        newIpadContentView.howMuch__c= howMuch;
                        newIpadContentView.ContentId__c= contentId;
                        insert newIpadContentView;
                    }
                    
                    //if the value is null, set it to 0
                    // this block is deprecated. 
                    
                    return 'true';
                }
                catch(Exception e)
                {
                    System.debug(e.getMessage());
                    return e.getMessage();
                }
        }else {
          return 'true';
        }
        
    }
    
    */
    
}