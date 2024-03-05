public with sharing class Ortho_GroupsService {


    public static List<CollaborationGroup> communicationGroups { get {
        if(communicationGroups == null){
            communicationGroups = [Select Id, Name from CollaborationGroup where Name in: (groupNames)];
        }
        return communicationGroups;
    }set;}

    public static Set<String> groupNames { get{ 
        if(groupNames == null){
            groupNames = new Set<String>();
            Ortho_Mobile_Setting__mdt[] orthoMobileSettings = Ortho_SettingsService.getSettingByType('Communication Group');
            for(Ortho_Mobile_Setting__mdt oms : orthoMobileSettings){
                groupNames.add(oms.Value__c);
            }
            System.debug('groupNames--------'+groupNames);
        }
        return groupNames;
    }set;}
}