/**   
*     ContentLastModifiedServerHelperTest: set Last_Modified_on_Server__c to today if update was not performed by iPad WSDL
*        Tests: ContentVersionBeforeInsertUpdate.trigger; ContentLastModifiedServerHelper.cls
*    
*     @author  Dave Ankit
*     @date    Jul 13  2015
*     @version 1.1 
*     
*/

@isTest
private class ContentLastModifiedServerHelperTest {

    /**
    *   UseCase: 
    *   1. Select an existing ContentWorkspace
    *   2. Insert 2 new ContentVersion records
    *   3. Insert a corresponding ContentWorkspaceDoc that references the ContentWorkspace and the ContentVersion.ContentDocumentID
    *   4. Update the tags on the ContentVersion records
    *   Expected:
    *   The ContentVersion.Last_Modified_on_Server__c field set to today
    */
    static testMethod void lastModifiedServerTest() {
        Set<ID> contentVersionIds = new Set<ID>();
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        List<ContentWorkspaceDoc> contentWorkDocs = new List<ContentWorkspaceDoc>();
        ID contentWorkSpaceID;
        
        // query for the Workspace ID, error and quit if one is not found
        try{
            contentWorkSpaceID = [Select id From ContentWorkspace Where Name = 'Deployment Folder' Limit 1].id;
        }
        catch(QueryException e){
            System.debug('I am in' + e.getMessage());
            //System.assert(false);
        }
         system.debug('checking content' +contentWorkSpaceID);
        Test.startTest();
        
        // insert new ContentVersion records
        for(Integer i = 0; i < 2; i++){
            contentVersions.add(new ContentVersion(
                Title = 'Test Title ' + i,
                PathOnClient = 'C:\FilePath' + i + '.txt',
                VersionData = Blob.valueOf('Test Content Version File Body')
            ));
        }
        insert contentVersions;     
        
        // create a set of the new ContentVersion record IDs
        for(ContentVersion cv : contentVersions){
            contentVersionIds.add(cv.ID);
        }
        
        // get updated values on ContentVersion records
        contentVersions.clear();
        contentVersions = [Select ID, Title, ContentDocumentId, TagCsv, Last_Modified_on_Server__c, iPad_Content_Views__c 
            From ContentVersion Where id In :contentVersionIds];
        system.debug(' check versions:' + contentVersions);
        
        // create the ContentWorkspaceDoc for each ContentVersion record
        // update tag on ContentVersion records
       /* for(ContentVersion cv : contentVersions){
            contentWorkDocs.add(new ContentWorkspaceDoc(
                ContentDocumentId = cv.ContentDocumentId,
                ContentWorkspaceId = contentWorkSpaceID
            ));
            
            cv.TagCsv = 'Test Tag';
        }
        insert contentWorkDocs;*/
        update contentVersions;
        
        Test.stopTest();
        
        // get updated values on ContentVersion records
        contentVersions.clear();
        contentVersions = [Select ID, Title, ContentDocumentId, TagCsv, Last_Modified_on_Server__c, iPad_Content_Views__c 
            From ContentVersion Where id In :contentVersionIds];
                
        // check that Last_Modified_on_Server__c has been set
        for(ContentVersion cv : contentVersions){
            System.assertEquals(System.today(), cv.Last_Modified_on_Server__c);
        }
    }
    
    /**
    *   UseCase: 
    *   1. Select an existing ContentWorkspace
    *   2. Insert 2 new ContentVersion records
    *   3. Insert a corresponding ContentWorkspaceDoc that references the ContentWorkspace and the ContentVersion.ContentDocumentID
    *   4. Set the iPad_Content_Views__c on the ContentVersion records to 10
    *   5. Set Last_Modified_on_Server__c to 01/01/1980
    *   6. Update the ContentVersion records
    *   Expected:
    *   The ContentVersion.Last_Modified_on_Server__c field will remain set to 01/01/1980
    */
    static testMethod void lastModifiedServerIPadViewsTest() {
        Set<ID> contentVersionIds = new Set<ID>();
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        List<ContentWorkspaceDoc> contentWorkDocs = new List<ContentWorkspaceDoc>();        
        ID contentWorkSpaceID;
        
        // query for the Workspace ID, error and quit if one is not found
        try{
            contentWorkSpaceID = [Select id From ContentWorkspace Where Name = 'Deployment Folder' Limit 1].id;
        }
        catch(QueryException e){
            System.debug(e.getMessage());
            //System.assert(false);
        }
        
        Test.startTest();
        
        // insert new ContentVersion records
        for(Integer i = 0; i < 2; i++){
            contentVersions.add(new ContentVersion(
                Title = 'Test Title ' + i,
                PathOnClient = 'C:\FilePath' + i + '.txt',
                VersionData = Blob.valueOf('Test Content Version File Body')
            ));
        }
        insert contentVersions;     
        
        // create a set of the new ContentVersion record IDs
        for(ContentVersion cv : contentVersions){
            contentVersionIds.add(cv.ID);
        }
        
        // get updated values on ContentVersion records
        contentVersions.clear();
        contentVersions = [Select ID, Title, ContentDocumentId, TagCsv, Last_Modified_on_Server__c, iPad_Content_Views__c 
            From ContentVersion Where id In :contentVersionIds];
        
        // create the ContentWorkspaceDoc for each ContentVersion record
        // update iPad_Content_Views__c on ContentVersion records
        // update Last_Modified_on_Server__c to a date in the past to test that it is not updated
        /*for(ContentVersion cv : contentVersions){
            contentWorkDocs.add(new ContentWorkspaceDoc(
                ContentDocumentId = cv.ContentDocumentId,
                ContentWorkspaceId = contentWorkSpaceID
            ));
            
            cv.iPad_Content_Views__c = 10;
            cv.Last_Modified_on_Server__c = date.parse('01/01/1980');
        }
        insert contentWorkDocs;*/
        update contentVersions;
        
        Test.stopTest();
        
        // get updated values on ContentVersion records
        contentVersions.clear();
        contentVersions = [Select ID, Title, ContentDocumentId, TagCsv, Last_Modified_on_Server__c, iPad_Content_Views__c 
            From ContentVersion Where id In :contentVersionIds];
                
        // check that Last_Modified_on_Server__c has been set
        for(ContentVersion cv : contentVersions){
            //System.assertEquals(10, cv.iPad_Content_Views__c);
            //System.assertEquals(date.parse('01/01/1980'), cv.Last_Modified_on_Server__c);
        }
    }
}