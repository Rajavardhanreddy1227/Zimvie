global with sharing class MedCertSyncSchedulableJob implements Schedulable {

    global void execute(SchedulableContext sc) {
        MedCertDailySyncJob b = new MedCertDailySyncJob(); 
        database.executebatch(b);
     }

}