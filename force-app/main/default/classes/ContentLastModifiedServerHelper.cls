/**   
*     ContentLastModifiedServerHelper: set Last_Modified_on_Server__c to today if update was not performed by iPad WSDL
*        Called by ContentVersionBeforeInsertUpdate.trigger
*    
*     @author  Denise Bacher
*     @date    Jan 5 2012
*     @version 1.0 
*     
*/

public with sharing class ContentLastModifiedServerHelper {

    /**
    * @author Denise Bacher
    * @date 01/05/2012
    * @param newContent List of ContentVersion from the trigger 
    * @param oldContent Map of old ContentVersion from the trigger
    * @description On update compile a list of ContentVersion records that have been not been updated by the WSDL and set Last_Modified_on_Server__c to today
    */
    public static void isUpdate(List<ContentVersion> newContent, Map<ID, ContentVersion> oldContent){
        System.debug('**** isUpdate');
        List<ContentVersion> content = new List<ContentVersion>();
        for(ContentVersion cv : newContent){
            System.debug('****** ContentVersion: ' + cv.Title + ', iPadViews=' + cv.iPad_Content_Views__c + ' old iPadViews=' +oldContent.get(cv.ID).iPad_Content_Views__c);
            // if iPad_Content_Views__c has been changed, we don't want to update Last_Modified_on_Server__c
            if(cv.iPad_Content_Views__c == oldContent.get(cv.ID).iPad_Content_Views__c){
                content.add(cv);
            }
        }
        
        if(content.size() > 0){
            System.debug('**** updating ' + content.size() + ' of ' + newContent.size());
            setLastModifiedOnServer(content);
        }
    }
    
    /**
    * @author Denise Bacher
    * @date 01/05/2012
    * @param newContent List of ContentVersion from the trigger 
    * @description On insert set Last_Modified_on_Server__c to today
    */
    public static void isInsert(List<ContentVersion> newContent){
        System.debug('**** isInsert');
        setLastModifiedOnServer(newContent);
    }
    
    /**
    * @author Denise Bacher
    * @date 01/05/2012
    * @param content List of ContentVersion records
    * @description Set Last_Modified_on_Server__c to today
    */
    private static void setLastModifiedOnServer(List<ContentVersion> content){
        System.debug('**** setLastModifiedOnServer');
        for(ContentVersion cv : content){
            cv.Last_Modified_on_Server__c = System.today();
            System.debug('****** ContentVersion: ' + cv.Title + ', Last_Modified_on_Server__c=' + cv.Last_Modified_on_Server__c);
        }
    }
}