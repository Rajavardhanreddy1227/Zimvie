/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class iPadContentViewIncreaseByTest {
/*
    static testMethod void increaseViewCountByTest() {
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

        System.debug('Running increaseCountBy true assertion');       
        System.assert(iPadContentViewIncreaseBy.increaseViewCountBy(existingContentRecord.Id, 4) == 'true');
        System.assert(iPadContentViewIncreaseBy.increaseViewCountBy(existingContentRecord.Id, 6) == 'true');
        //existingContentRecord.iPad_Content_Views__c = null;
        //update existingContentRecord;
        //System.assert(iPadContentViewIncreaseBy.increaseViewCountBy(existingContentRecord.Id, 4) == 'true');
        //negative test 
        //System.assert(iPadContentViewIncreaseBy.increaseViewCountBy('06830000000ZFfSAAW', 4) != 'true');
         
      
        List<iPad_Content_Views__c> ipadContentViewList = [Select Id, ContentId__c , howMuch__c from iPad_Content_Views__c where ContentId__c =:existingContentRecord.Id];  
        System.debug('ipadContentViewIncreseByTest:ipadContentViewList.size()='+ ipadContentViewList.size());
        System.assert(ipadContentViewList.size()>0);
        System.assertEquals(10, ipadContentViewList[0].howMuch__c);
        
    }
    */
}