/**
* @author Manish Vashistha - Zimmer Biomet.
* @date December, 2020
*
* @group HCF_Surgeon_Certification__c
*
* @description The batch job will keep records in sync with Healthcare_Surgeon_Relationship__c
*/
global class MedCertDailySyncJob  implements Database.Batchable<sObject> {
    public MedCertDailySyncJob() {

    }

    private String query;
    private List<Id> lstSrgn;
    global Database.QueryLocator start(Database.BatchableContext bc) {  
        Datetime d = Datetime.now();
        d = d.addHours(-24);
        //query = 'SELECT Id,Surgeon__c, Certification__c, Health_Care_Facility__c FROM HCF_Surgeon_Certification__c order by LastModifiedDate desc';
        query = 'SELECT Contact__r.AccountId, Id FROM Certification__c';
        return Database.getQueryLocator(query);
    }
    

    global void execute(Database.BatchableContext bc, List<Certification__c> lstSrgnCerts){
        // process each batch of records
        System.debug('Synchronizing ... Med Certifications : '+lstSrgnCerts.size());
        /*
        Set<Id> setUnqSrgns = new Set<Id>();    
        
        for (Certification__c i : lstSrgnCerts)
            setUnqSrgns.add(i.Contact__r.AccountId);

        //Create the List Variable
        List<Id> unqSrgns  = new List<Id>();
        unqSrgns.addAll(setUnqSrgns);
        */
        if(!lstSrgnCerts.isEmpty()) 
        {            
            MedCert_Util.syncMedCertifications(lstSrgnCerts);            
        }        
    }
        

    global void finish(Database.BatchableContext bc){
        System.debug('Med Cert Synchronization Job Completed.');

        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
        TotalJobItems, CreatedBy.Email
        FROM AsyncApexJob WHERE Id =
        :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        System.debug('The Job Id :'+ BC.getJobId() + ' is created by '+a.CreatedBy.Email);
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Med Cert Synchronization ' + a.Status);
        mail.setPlainTextBody
        ('The batch Apex job processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}