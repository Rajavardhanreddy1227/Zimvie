/**
 * @description       : 
 * @author            : hugodhm@icloud.com
 * @group             : 
 * @last modified on  : 12-06-2021
 * @last modified by  : hugodhm@icloud.com
**/
public class ContentTriggerHandler {
    public static void createPublicLinkForFile(List<ContentVersion> contentVersions){
        ContentDistribution[] distributionsToInsert = new List<ContentDistribution>();
        Map<Id,ContentVersion> mapContentDocumentIdToCV = new Map<Id,ContentVersion>();
        for(ContentVersion cv : contentVersions)
            mapContentDocumentIdToCV.put(cv.ContentDocumentId,cv);
        List<ContentDocument> listContentDocument = [SELECT ID, Title FROM CONTENTDOCUMENT WHERE ID IN :mapContentDocumentIdToCV.keySet()];
        
       	for(ContentDocument cd : listContentDocument){
            if(cd.title.contains(PhotoManagementController.PHOTO_NAME))
            	distributionsToInsert.add(createContentDistribution(mapContentDocumentIdToCV.get(cd.Id).Id));
            
        }
        if(!distributionsToInsert.isEmpty())
        {
        	insert distributionsToInsert;
        }
    }
    
    public static ContentDistribution createContentDistribution(Id contentVersionId){
        ContentDistribution newDist = new ContentDistribution();
        newDist.ContentVersionId = contentVersionId;
        newDist.Name = 'External Link';
        newDist.PreferencesNotifyOnVisit = false;
        newDist.PreferencesAllowViewInBrowser = true;
        newDist.PreferencesAllowOriginalDownload=true;
        system.debug(contentVersionId);
        return newDist;
    }
}