trigger UpdateRepDetail on DN_Zip_Code_Lookup__c (After Update) {
    UpdateRepDetailHelper.updateRepName(Trigger.new,trigger.OldMap);
}