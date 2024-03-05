trigger UpdateDNZipCodeRepName on User (after update) {
    UpdateDNZipCodeRepNameHelper.updateRepName(Trigger.new,trigger.OldMap);
}