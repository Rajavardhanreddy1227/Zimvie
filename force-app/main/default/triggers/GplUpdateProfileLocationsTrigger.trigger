trigger GplUpdateProfileLocationsTrigger on GPL_Location__c (after delete, after insert, after update) {
    set<Id> ids = new set<Id>();
    for (Integer i=0;i<trigger.old.size();i++){
        GPL_Location__c location = trigger.old[i];
        Id profile = location.GPL_Profile__c;
        ids.add(profile);
    }
    list<GPL_Location__c> locations = [SELECT Id, Name__c, Street__c, /*City__c, State__c,*/ PostalCode__c, 
                                        Country__c, GPL_Profile__c, GPL_Profile__r.Locations__c
                                        FROM GPL_Location__c 
                                        WHERE GPL_Profile__c in :ids ];
    map<GPL_Profile__c, set<GPL_Location__c>> locsByProf = new map<GPL_Profile__c, set<GPL_Location__c>>();
    for (GPL_Location__c l : locations){
        set<GPL_Location__c> locs = locsByProf.get(l.GPL_Profile__r);
        if (locs == null){
            locs = new set<GPL_Location__c>();
        }
        locs.add(l);
        locsByProf.put(l.GPL_Profile__r, locs);
    }
    set<GPL_Profile__c> profiles = locsByProf.keySet();
    for (GPL_Profile__c profile : profiles){
        set<GPL_Location__c> locs = locsByProf.get(profile);
        String val = '<table class="list" border="0" cellpadding="0" cellspacing="0">' +
                     '<tbody>' +
                     '<tr class="headerRow">' + 
                     '<th scope="col" class=" zen-deemphasize">Name</th>' +
                     '<th scope="col" class=" zen-deemphasize">City</th>' +
                     '<th scope="col" class=" zen-deemphasize">State</th>' +
                    // '<th scope="col" class=" zen-deemphasize">Postal Code</th>' +
                    // '<th scope="col" class=" zen-deemphasize">Country</th>' +
                     '</tr>';
        for (GPL_Location__c l : locs){
            val +=   '<tr class="dataRow">' +
                     '<td class=" dataCell">' + l.Name__c + '</td>' +
                     '<td class=" dataCell">' + l.City__c + '</td>' +
                     '<td class=" dataCell">' + l.State__c + '</td>' +
                    // '<td class=" dataCell">' + l.PostalCode__c + '</td>' +
                    // '<td class=" dataCell">' + l.Country__c + '</td>' +
                     '</tr>';                       
        }
        val +=       '</tbody>' +
                     '</table>';
        profile.Locations__c = val;                  
    }
    if (!profiles.isEmpty()){
        list<GPL_Profile__c> x = new list<GPL_Profile__c>();
        x.addAll(profiles);
        update x;
    }
}