public class UpdateDNZipCodeRepNameHelper {
    public static void updateRepName(List<User> Triggernew , Map<Id,User> TriggerOldMap){
        List<String> oldZipCode = new List<String>();
        Map<String,User> newZipCodeMap = new Map<String,User>();
        Map<Id,Id> dnZipCodeRepNameMap = new Map<Id,Id>();
        Map<Id,Id> dnZipCodeManagerNameMap = new Map<Id,Id>();
        Map<String,Id> aliasManagerIdMap = new Map<String,Id>();
        Map<Id,String> aliasDNZipIdMap = new Map<Id,String>();
        List<DN_Zip_Code_Lookup__c> dnZipCodeLookupToUpdate = new List<DN_Zip_Code_Lookup__c>();
        List<Lead> leadToUpdate = new List<Lead>();
        for(User usr : Triggernew){
            if(TriggerOldMap.get(usr.Id).Alias != usr.Alias){
                oldZipCode.add(TriggerOldMap.get(usr.Id).Alias);
                newZipCodeMap.put(usr.Alias,usr);
            }
            
            if(TriggerOldMap.get(usr.Id).ManagerId != usr.ManagerId){
                aliasManagerIdMap.put(usr.Alias,usr.ManagerId);
            }
        }
        for(DN_Zip_Code_Lookup__c dnZipCode : [Select id,Rep_Name__c,Salesforce_Alias__c from DN_Zip_Code_Lookup__c
                                              where Salesforce_Alias__c In :aliasManagerIdMap.keySet() ]){
            aliasDNZipIdMap.put(dnZipCode.Id,dnZipCode.Salesforce_Alias__c);
        }
        for(DN_Zip_Code_Lookup__c dnZipCode : [Select id,Rep_Name__c,Salesforce_Alias__c from DN_Zip_Code_Lookup__c Where 
                                               (Salesforce_Alias__c IN : oldZipCode OR Salesforce_Alias__c In : newZipCodeMap.keySet()) ]){
                                                   if(oldZipCode.contains(dnZipCode.Salesforce_Alias__c)){
                                                       //dnZipCode.Salesforce_Alias__c ='';
                                                       dnZipCode.Rep_Name__c =null;
                                                       dnZipCodeRepNameMap.put(dnZipCode.id,null);
                                                       dnZipCodeManagerNameMap.put(dnZipCode.id,null);
                                                   }
                                                   else if(newZipCodeMap.containsKey(dnZipCode.Salesforce_Alias__c)){
                                                       dnZipCode.Rep_Name__c =newZipCodeMap.get(dnZipCode.Salesforce_Alias__c).id;
                                                       dnZipCodeRepNameMap.put(dnZipCode.id,dnZipCode.Rep_Name__c);
                                                       dnZipCodeManagerNameMap.put(dnZipCode.id,newZipCodeMap.get(dnZipCode.Salesforce_Alias__c).Managerid);
                                                   }
                                                   dnZipCodeLookupToUpdate.add(dnZipCode);
                                               }
        
        for(lead ld : [Select id,Co_Owner__c,DN_Zip_Code_Lookup__c,Secondary_Co_Owner__c from lead 
                       where (DN_Zip_Code_Lookup__c In : dnZipCodeRepNameMap.keySet() or DN_Zip_Code_Lookup__c In : aliasDNZipIdMap.keyset()) and recordType.developerName='DN_NAM_MKTG']){
                           if(dnZipCodeRepNameMap.containsKey(ld.DN_Zip_Code_Lookup__c)){
                               ld.Co_Owner__c =dnZipCodeRepNameMap.get(ld.DN_Zip_Code_Lookup__c);
                               ld.Secondary_Co_Owner__c = dnZipCodeManagerNameMap.get(ld.DN_Zip_Code_Lookup__c);
                           }
                           if(aliasDNZipIdMap.containsKey(ld.DN_Zip_Code_Lookup__c)){
                           	  ld.Secondary_Co_Owner__c = aliasManagerIdMap.get(aliasDNZipIdMap.get(ld.DN_Zip_Code_Lookup__c));  
                           }
                           leadToUpdate.add(ld);
                       }
        if(dnZipCodeLookupToUpdate.size() > 0){
            Update dnZipCodeLookupToUpdate;
        }
        
        if(leadToUpdate.size() > 0){
            Update leadToUpdate;
        }
    }    
}