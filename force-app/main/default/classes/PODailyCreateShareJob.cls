/**
* @author Manish Vashistha - Zimmer Biomet.
* @date December, 2020
*
* @group Purchase_Order__c
*
* @description This is a batch job which required to run one time to
* create Purchase Order Share records
*/
global class PODailyCreateShareJob implements Database.Batchable<sObject> {

    public String query;
    private List<Territory2> lstTerr;
    global Database.QueryLocator start(Database.BatchableContext bc) {  
        Datetime d = Datetime.now();
        d = d.addHours(-24);
        query = 'SELECT Id,Territory2_ID__c, Name, OwnerId FROM Purchase_Order__c Where LastModifiedDate >= '+d.format('yyyy-MM-dd')+'T'+d.format('HH:mm')+':00.000Z order by LastModifiedDate desc';
        return Database.getQueryLocator(query);        
    }
    

    global void execute(Database.BatchableContext bc, List<Purchase_Order__c> lstPOS){
        // process each batch of records
        System.debug('Processing ... Purchase Orders for Share Recalculation : '+lstPOS.size());

        if(!lstPOS.isEmpty()) 
        {            
            PO_Util.createPOSharesForPurchaseOrders(lstPOS);            
        }        
    }
        

    global void finish(Database.BatchableContext bc){
        System.debug('Purchase Order Share Creation Job Completed.');

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
        mail.setSubject('Apex Sharing Recalculation ' + a.Status);
        mail.setPlainTextBody
        ('The batch Apex job processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}