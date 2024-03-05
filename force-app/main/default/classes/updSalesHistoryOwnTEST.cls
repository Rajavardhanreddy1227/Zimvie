// ** Test Script for Sales History Owner Change Trigger.
@isTest
private class updSalesHistoryOwnTEST  {
	
    static User testUser; 
    static Id testRecordTypeId;

    private static void setupData(){
        Profile profile = [select Id from Profile where name = 'System Administrator' limit 1];
        
        User userObj = new User(alias = 'dentalca', email='dentalca@testorg.com',
        emailencodingkey='UTF-8', lastname='TestUsers1', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profile.Id,
        timezonesidkey='America/Los_Angeles', username='dentalcas@testorg.com', isActive=true, 
        Region__c='AM', Geography__c='US', Business_Division__c='DN');
        insert userObj;

        System.assert(userObj.Id != null);       
        testUser = userObj;

        System.debug('-----updSalesHistoryOwnTEST.setupData-testUser----- = ' + testUser);

        String dentalCanadaRecordType = null;
        List<RecordType> recordTypeList = [Select Id From RecordType Where SobjectType = 'Account' and DeveloperName = 'DN_EU_Ghost_Account' LIMIT 1];
        for (RecordType recordType : recordTypeList) {
            dentalCanadaRecordType = recordType.Id;
        }
        
        System.assert(dentalCanadaRecordType != null);       
        testRecordTypeId = dentalCanadaRecordType;

        System.debug('-----updSalesHistoryOwnTEST.setupData-testRecordTypeId----- = ' + testRecordTypeId);      
    }

    static testMethod void BulkUpdateTriggerTest() {
        setupData(); 
        System.runAs(testUser){
            // TEST BATCH UPDATES
            // This test will cover Sales History Updates that exceed
            // the the DML record limit on triggers 
            // ** NOTE ** TEST ups the limit to 500, so it's impossible
            // to test using the trigger. And if we try to exceed the 500
            // DML limit we hit another issue - max. batch in test is also 500
            // So the only way to test is to force the routine to run by passing in 
            // the account

            // Create Test Account
            Account a = new Account();
            a.Name = 'TESTAPEX';
            a.OwnerId = Userinfo.getUserId() ;
            a.RecordTypeId = testRecordTypeId;
            insert a;
            system.debug(' ---> [BulkUpdateTriggerTest] Owner Id ' + a.OwnerId );
            system.debug(' ---> [BulkUpdateTriggerTest] Created By ' + a.CreatedById );
            system.debug(' ---> [BulkUpdateTriggerTest] Account Name ' + a.Name );
        
            // Insert 200 Test Sales History Records(Invoices)
            List<Sales_History__c> salesHistory = new list<sales_history__C>{};

            for (integer i = 0; i < 200; i++) {
                Sales_History__c SalesHist = new Sales_History__c();
                SalesHist.Name = 'TEST' + i; 
                //SalesHist.OwnerId = a.OwnerID;
                SalesHist.Account__c = a.ID;
                // Insert test record to list bulk update outside of loop
                salesHistory.add(SalesHist);
            }
            // Bulk Insert records
            insert salesHistory;

            // Fire update trigger by changing ownership on Account record
            a.OwnerID = testUser.Id;
            update a;
        
            // Force call to batch processing
            Set<ID> AccountIDs = new Set<ID>();
            AccountIDs.add(a.ID);
            updSalesHistOwner.OwnerUpdate(AccountIDs);  
            
            // Added to get code coverage for updSalesHistOwnerNow. remove if required to Activate the class in production.
            updSalesHistOwnerNow.OwnerUpdate(AccountIDs);
        }
    }
    
    static testMethod void SyncUpdateTriggerTest() {
        setupData(); 
        System.runAs(testUser){
            // TEST SYNCHRONOUS UPDATES
            // This test will cover Sales History Updates that are
            // within the 100 DML record limit on triggers. This
            // will cause the update to occur as part of the triggers
            // stream

            // Create Test Account
            Account a = new Account();
            a.Name = 'TESTAPEX';
            a.OwnerId = Userinfo.getUserId() ;
            a.RecordTypeId = testRecordTypeId;
            insert a;
            system.debug(' ---> [SyncUpdateTriggerTest] Owner Id ' + a.OwnerId );
            system.debug(' ---> [SyncUpdateTriggerTest] Created By ' + a.CreatedById );
            system.debug(' ---> [SyncUpdateTriggerTest] Account Name ' + a.Name );
        
        
            // Insert 99 Test Sales History Records
            List<Sales_History__c> salesHistory = new list<sales_history__C>{};
        
            for (integer i = 0; i < 99; i++) {
                Sales_History__c SalesHist = new Sales_History__c();
                SalesHist.Name = 'TEST' + i; 
                //SalesHist.OwnerId = a.OwnerID;
                SalesHist.Account__c = a.ID;
                // Insert test record to list bulk update outside of loop
                salesHistory.add(SalesHist);
            }
            // Bulk Insert records
            insert salesHistory;

            // Fire update trigger by changing ownership on Account record
            a.OwnerID = testUser.Id;
            update a;           
        }
    }
    
    static testMethod void NoUpdatesTriggerTest() {
        setupData();
        System.runAs(testUser){
            // NO ACCOUNTS TO UPDATE
            // This test will cover the scenario where the trigger
            // is fired but the account owner has not changed, therefore
            // there is nothing to do.

            // Create Test Account
            Account a = new Account();
            a.Name = 'TESTAPEX';
            a.OwnerId = Userinfo.getUserId() ;
            a.RecordTypeId = testRecordTypeId;
            a.Site = 'TEST SITE';
            insert a;
            system.debug(' ---> [NoUpdatesTriggerTest] Owner Id ' + a.OwnerId );
            system.debug(' ---> [NoUpdatesTriggerTest] Created By ' + a.CreatedById );
            system.debug(' ---> [NoUpdatesTriggerTest] Account Name ' + a.Name );
        
            // Fire update trigger by changing site on Account record
            a.Site = 'ANOTHER SITE';
            update a;           
        } 
    }
    
    static testMethod void NoSalesHistoryToUpdateTest() {
        setupData(); 
        System.runAs(testUser){
            // NO SALES HISTORY TO UPDATE
            // This test will cover the trigger firing with an Account Owner
            // Change and not Sales History records to update.

            // Create Test Account
            Account a = new Account();
            a.Name = 'TESTAPEX';
            a.OwnerId = Userinfo.getUserId() ;
            a.RecordTypeId = testRecordTypeId;
            insert a;
            system.debug(' ---> [NoSalesHistoryToUpdateTest] Owner Id ' + a.OwnerId );
            system.debug(' ---> [NoSalesHistoryToUpdateTest] Created By ' + a.CreatedById );
            system.debug(' ---> [NoSalesHistoryToUpdateTest] Account Name ' + a.Name );
        
            // Fire update trigger by changing ownership on Account record
            a.OwnerID = testUser.Id;
            update a;           
        }
    }
    
}