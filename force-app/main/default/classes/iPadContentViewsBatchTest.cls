/**   
*     Test Class for iPadContentViewsBatch
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
*     specification : update test to create it's own content record instead of using one existing on the server
*     author:       Denise B
*     date:         Jan 17 2012
*     
*     
*     Description: 
*     create a Scheduled Batch Apex job that runs every night at 1:00AM 
*     that reads through each record on the custom object, 
*     and updates the Content records with those values. 
*     These iPad_Content_Views__c records should then be deleted.
*/
 /**
    *   UseCase: 
    *   1. chose 1 existing contentVersion
    *   2. create iPad_Content_Views__c record related to the existing contentVersion
    *   3. update the iPad_Content_Views__c.howMuch__c to 21
    *   4. insert the iPad_Content_Views__c 
    *   5. execute iPadContentViewsBatch
    *   Expected:
    *   the exisiting ContentVersion.iPad_Content_Views__c field incremented  by 21
    */ 
    
    /* 
        Note: Not a great practice to use an existing record, but there's no way to Insert a Workspace from Apex.
        This chooses a random workspace, and adds a new content record to it to run the tests on.
    */ 
    
@isTest
private class iPadContentViewsBatchTest {
    /*
    public Decimal OriginalValue {
            get;
            set;
    }
    public Id ExistingContentVersionId {
           get;
           set;
    }
    
    public void setup(){
    
        iPad_Content_Views__c ipcv = new iPad_Content_Views__c ();
        ContentVersion existingContentRecord;
        ContentWorkspaceDoc existingContentWorkDoc;
        ID contentWorkSpaceID;
        
        // query for the Workspace ID, error and quit if one is not found
        try{
            contentWorkSpaceID = [Select id From ContentWorkspace Where Name = 'Deployment Folder' Limit 1].id;
        }
        catch(QueryException e){
            System.debug(e.getMessage());
            System.assert(false);
        }
        
        existingContentRecord = new ContentVersion(
            Title = 'Test Title',
            PathOnClient = 'C:\FilePath.txt',
            VersionData = Blob.valueOf('Test Content Version File Body'));
        insert existingContentRecord;
        existingContentRecord = [Select ID, Title, ContentDocumentId, TagCsv, Last_Modified_on_Server__c, iPad_Content_Views__c 
                                 From ContentVersion Where id =: existingContentRecord.id Limit 1];
        
        existingContentWorkDoc = new ContentWorkspaceDoc(
                ContentDocumentId = existingContentRecord.ContentDocumentId,
                ContentWorkspaceId = contentWorkSpaceID);
        insert existingContentWorkDoc;
     
        if(existingContentRecord != null){
            if(existingContentRecord.iPad_Content_Views__c != null){
                OriginalValue = existingContentRecord.iPad_Content_Views__c;
            }else{
                OriginalValue = 0;
            }
            ExistingContentVersionId = existingContentRecord.Id;
            ipcv.ContentId__c = existingContentRecord.Id;
            ipcv.howMuch__c = 21;
        }
        insert ipcv;
        
    }
     
    
    static testMethod void testIPadContentViewsBatch() {
    
        iPadContentViewsBatchTest tes = new iPadContentViewsBatchTest();
        tes.setup();
        Test.startTest();
            String query='select '
                        + 'Id, ' 
                        + 'ContentId__c, '
                        + 'howMuch__c ' 
                        + 'from iPad_Content_Views__c where howMuch__c >0';  
            iPadContentViewsBatch ipcvBatch = new iPadContentViewsBatch(query);
            Id batchprocessid = Database.executeBatch(ipcvBatch);   
        Test.stopTest();
        ContentVersion updatedContentRecord = [SELECT Id,iPad_Content_Views__c FROM ContentVersion where Id = :tes.ExistingContentVersionId];
        System.Debug('iPadContentViewsBatchTest:updatedContentRecord.iPad_Content_Views__c='+updatedContentRecord.iPad_Content_Views__c+', should be ' + (tes.OriginalValue + 21) + ' -------------');
        //System.assertEquals(tes.OriginalValue + 21, updatedContentRecord.iPad_Content_Views__c);
        List<iPad_Content_Views__c> ipadContentViewList = [Select Id, ContentId__c , howMuch__c from iPad_Content_Views__c where ContentId__c =:tes.ExistingContentVersionId];  
        if(ipadContentViewList.size()>0){
            System.Debug('iPadContentViewsBatchTest:ipadContentViewList[0].howMuch__c='+ipadContentViewList[0].howMuch__c+', should be 0 -------------');
            //System.assertEquals(0, ipadContentViewList[0].howMuch__c);
        }
   
    }
    */
}