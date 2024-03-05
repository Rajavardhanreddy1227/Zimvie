trigger B2B_AccountTrigger on Account (after insert,after update) {
    if(Trigger.isAfter && Trigger.isInsert){
        Set<Id> setAccId = new Set<Id>();
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Ecommerce Account').getRecordTypeId();
        for(Account acc : Trigger.New){
            if(acc.IsBuyer == false && acc.Oracle_Pricelist_External_ID__c != null && acc.RecordTypeId == devRecordTypeId){
                setAccId.add(acc.Id);
            }
        }
        if(setAccId != null && setAccId.size() > 0){
            B2B_AccountEnablementBatch objBatch = new B2B_AccountEnablementBatch(setAccId);
            database.executebatch(objBatch);
        }
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        Set<Id> setAccId = new Set<Id>();
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Ecommerce Account').getRecordTypeId();
        for(Account acc : Trigger.New){
            if(acc.Oracle_Pricelist_External_ID__c != null && acc.Oracle_Pricelist_External_ID__c != Trigger.oldmap.get(acc.Id).Oracle_Pricelist_External_ID__c && acc.RecordTypeId == devRecordTypeId){
                setAccId.add(acc.Id);
            }
        }
        if(setAccId != null && setAccId.size() > 0){
            B2B_AccountEnablementBatch objBatch = new B2B_AccountEnablementBatch(setAccId);
            database.executebatch(objBatch);
        }
    }
    
}