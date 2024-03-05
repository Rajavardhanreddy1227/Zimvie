@isTest
public with sharing class PhotoManagementControllerTest {
    @TestSetup
    static void makeData() {
        Account physician = MigrationDataFactory.createPhysician();      
    }
    @isTest
    public static void testGetCurrentPhotoVersionIdCtr() {
        Account physician = [SELECT ID FROM ACCOUNT LIMIT 1];
        
        Test.startTest();
        String returnValue = PhotoManagementController.getCurrentPhotoVersionIdCtr(physician.Id);
        System.assert(String.isBlank(returnValue));
        Attachment photo = new Attachment();
        photo.Name=PhotoManagementController.PHOTO_NAME;
        photo.Body=Blob.valueOf('Test');
        photo.ParentId=physician.Id;
        insert photo;
        returnValue = PhotoManagementController.getCurrentPhotoVersionIdCtr(physician.Id);
        System.assert(String.isNotBlank(returnValue));
        Test.stopTest();
    }
    
    @isTest
    public static void testIsPhotoSizeAllowedCtr() {
        Account physician = [SELECT ID FROM ACCOUNT LIMIT 1];
        ContentVersion ContVerFile = new ContentVersion();
        ContVerFile.VersionData = Blob.valueOf('Test');
        ContVerFile.Title = PhotoManagementController.PHOTO_NAME; 
        ContVerFile.PathOnClient=PhotoManagementController.PHOTO_NAME+'.png';
        insert ContVerFile;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:ContVerFile.Id].ContentDocumentId;
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = physician.Id;
        cDe.ShareType = 'I';
        cDe.Visibility = 'AllUsers';
        insert cDe;
        Test.startTest();
        Boolean returnValue = PhotoManagementController.isPhotoSizeAllowedCtr(conDoc, physician.Id);
        System.assert(returnValue);
        Test.stopTest();
    }
}