public class GplManageProfilePhotoController {
    private final GPL_Profile__c profile;
    private ApexPages.standardController sc;
    public Attachment photo {
        get {
            if (photo == null){
                photo = new Attachment();
            }
            return photo;
        }
        set;
    }
    
    public GplManageProfilePhotoController(ApexPages.StandardController stdController){
        this.sc = stdController;
        this.profile = (GPL_Profile__c)stdController.getRecord();
    } 
    
    public PageReference savePhoto(){
        photo.ParentId = profile.Id;
        try {
            blob body = photo.Body;
            if (body.size() > 100000){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Image size must be less than 100K'));
                return null;
            }
            insert photo;
            profile.Picture_Id__c = photo.Id;
            update profile;
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
            return null;
        } finally {
            photo = new Attachment();
        }
        return new PageReference('/' + profile.Id);
    }
}