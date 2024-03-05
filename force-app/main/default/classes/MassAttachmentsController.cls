public class MassAttachmentsController {
    public MassAttachmentsController() {

    }
    public blob file { get; set; }
    public string fileName { get; set; }

    public PageReference upload() {
        ApexPages.getMessages().clear();
        
        try {
            List<String> parentIds = ApexPages.currentPage().getParameters().get('id').split(',');
            id pid = parentIds[0];
            List<ContentDocumentLink> filesToInsert = new List<ContentDocumentLink>();

            ContentVersion v = new ContentVersion();

            v.versionData = this.file;
            v.title = this.fileName;
            v.pathOnClient = '/' + this.fileName;

            insert v;

            Id contentVersionId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: v.Id].ContentDocumentId;

            for (String parentId : parentIds) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentVersionId;
                cdl.LinkedEntityId = parentId;
                cdl.ShareType = 'V';

                filesToInsert.add(cdl);
            }       

            insert filesToInsert;
            this.file = null;

            Apexpages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.CONFIRM, 'Upload successful.'));
            pagereference page = new PageReference ('/lightning/r/'+pid+'/related/CombinedAttachments/view');
            return page ;
        } catch(Exception ex) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'There was an error while uploading a file.'));
        }   

        return null;
    }
}