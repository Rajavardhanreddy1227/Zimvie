public with sharing class PhotoManagementController {
  public static Integer MAX_FILE_SIZE_IN_MB = 5 * 1048576;
  public static String PHOTO_NAME = 'Surgeon Photo';

  @AuraEnabled
  public static Id getCurrentPhotoVersionIdCtr(Id recordId) {
    if ([SELECT COUNT() FROM Attachment WHERE ParentId = :recordId AND Name LIKE :PHOTO_NAME + '%' LIMIT 1] > 0)
      return [SELECT Id FROM Attachment WHERE ParentId = :recordId AND  Name LIKE :PHOTO_NAME + '%' LIMIT 1].Id;
    return null;
  }

  @AuraEnabled
  public static boolean isPhotoSizeAllowedCtr(
    Id contentDocumentId,
    Id recordId
  ) {
    ContentDocument photo = [
      SELECT Id, Title, ContentSize
      FROM ContentDocument
      WHERE Id = :contentDocumentId
      LIMIT 1
    ];
    if (photo.contentsize <= MAX_FILE_SIZE_IN_MB) {
      Id attachmentId = saveAttachment(contentDocumentId, recordId);
      updateContentDocumentName(contentDocumentId);
      deletePreviousPhoto(attachmentId, recordId, contentDocumentId);
      setPhysicianPhotoURL(attachmentId, recordId);
      return true;
    } else {
      delete photo;
      return false;
    }
  }

  public static void setPhysicianPhotoURL(Id attachmentId, Id physicianId) {
    Account physician = [SELECT ID FROM ACCOUNT WHERE Id = :physicianId];
    physician.btydev__Picture_Id__pc = attachmentId;
    update physician;
  }

  public static Id saveAttachment(Id contentDocumentId, Id physicianId) {
    Attachment photoAttachment = new Attachment();
    ContentVersion photoContentVersion = [
      SELECT FileExtension, versionData
      FROM ContentVersion
      WHERE ContentDocumentId = :contentDocumentId
    ];
    photoAttachment.Name = PHOTO_NAME + '.' + photoContentVersion.FileExtension;
    photoAttachment.ParentId = physicianId;
    photoAttachment.Body = photoContentVersion.versionData;
    insert photoAttachment;
    return photoAttachment.Id;
  }

  public static void deletePreviousPhoto(Id attachmentId, Id parentId, Id contentDocumentId) {
    delete [
      SELECT ID
      FROM Attachment
      WHERE Id != :attachmentId AND Name LIKE :PHOTO_NAME + '%' AND ParentId=:parentId
    ];
      List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :parentId];
      Set<Id> CDSet = new Set<Id>();
      for(ContentDocumentLink cdl : contentDocumentLinks){
          if(cdl.ContentDocumentId != contentDocumentId)
          	cdset.add(cdl.ContentDocumentId);
      }
    List<ContentVersion> CVList = [SELECT ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :cdset AND Title LIKE :PHOTO_NAME+'%'];
      Set<Id> CDToDeleteSet = new Set<Id>();
      for(ContentVersion cv : CVList){
          CDToDeleteSet.add(cv.ContentDocumentId);
      }
      delete [SELECT ID FROM CONTENTDOCUMENT WHERE ID IN :CDTodeleteSet];
  }

  public static void updateContentDocumentName(Id contentDocumentId) {
    ContentDocument cd = [SELECT ID,Title FROM ContentDocument WHERE Id = :contentDocumentId];
    cd.Title  = PHOTO_NAME;
      update cd;
  }
}