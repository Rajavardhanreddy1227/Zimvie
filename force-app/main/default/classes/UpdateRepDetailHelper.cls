public class UpdateRepDetailHelper {
public static void updateRepName(List<DN_Zip_Code_Lookup__c> Triggernew , Map<Id,DN_Zip_Code_Lookup__c> TriggerOldMap){
    	List<DN_Zip_Code_Lookup__c> dnZipCodeLookupToUpdate = new List<DN_Zip_Code_Lookup__c>();
     	Map<Id,String> dnZipCodeRepIdMap = new Map<Id,String>();
    	Map<String,User> userManagerIdMap = new Map<String,User>();
        List<Lead> leadToUpdate = new List<Lead>();
        for(DN_Zip_Code_Lookup__c zipCode : Triggernew){
            if(TriggerOldMap.get(zipCode.Id).Salesforce_Alias__c != zipCode.Salesforce_Alias__c){
                dnZipCodeRepIdMap.put(zipCode.Id,zipCode.Salesforce_Alias__c);
            }
        }
        System.debug(':::dnZipCodeRepIdMap:::'+dnZipCodeRepIdMap);
        for(User usr : [Select id,ManagerId,alias from User where alias In :dnZipCodeRepIdMap.values()]){
            userManagerIdMap.put(usr.alias,usr);
        }
    	for(DN_Zip_Code_Lookup__c zipCode : Triggernew){
            if(TriggerOldMap.get(zipCode.Id).Salesforce_Alias__c != zipCode.Salesforce_Alias__c){
                DN_Zip_Code_Lookup__c recordToUpdate = new DN_Zip_Code_Lookup__c(Id=zipCode.Id);
                if(userManagerIdMap.containsKey(zipCode.Salesforce_Alias__c)){
                    
                	recordToUpdate.Rep_Name__c = userManagerIdMap.get(zipCode.Salesforce_Alias__c).Id;
                }
                else{
                    recordToUpdate.Rep_Name__c =null;
                }
                dnZipCodeLookupToUpdate.add(recordToUpdate);
            }
        }
        System.debug(':::userManagerIdMap:::'+userManagerIdMap);
        for(lead ld : [Select id,Co_Owner__c,DN_Zip_Code_Lookup__c,Secondary_Co_Owner__c from lead 
                       where (DN_Zip_Code_Lookup__c In : dnZipCodeRepIdMap.keySet() and recordType.developerName='DN_NAM_MKTG') and recordType.developerName='DN_NAM_MKTG']){
                           if(String.isNotBlank(dnZipCodeRepIdMap.get(ld.DN_Zip_Code_Lookup__c))){
                               User usr = userManagerIdMap.get(dnZipCodeRepIdMap.get(ld.DN_Zip_Code_Lookup__c));
                               System.debug(':::usr:::'+usr);
                               ld.Co_Owner__c = usr != null ? usr.id: null;
                           	   ld.Secondary_Co_Owner__c = usr != null ? usr.ManagerId: null;
                           }
                           else{
                               ld.Co_Owner__c = null;
                           	   ld.Secondary_Co_Owner__c = null;
                           }
                           System.debug(':::Co_Owner__c:::'+ld.Co_Owner__c);
                           System.debug(':::Secondary_Co_Owner__c:::'+ld.Secondary_Co_Owner__c);
                           leadToUpdate.add(ld);
                       }
        
        if(leadToUpdate.size() > 0){
            Update leadToUpdate;
        }
    if(dnZipCodeLookupToUpdate.size() > 0){
            Update dnZipCodeLookupToUpdate;
        }
    
    
    }   
}