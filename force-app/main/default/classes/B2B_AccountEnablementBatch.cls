global class B2B_AccountEnablementBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Set<Id> setAccId;
    global List<BuyerGroupMember> lstBGM;
    global B2B_AccountEnablementBatch(Set<Id> setAccId){
        this.setAccId = setAccId;
        lstBGM = new List<BuyerGroupMember>();
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Ecommerce Account').getRecordTypeId();
        Datetime last24Hours = Datetime.now().addDays(-1);
        String query = 'SELECT Id, Name,Oracle_Pricelist_External_ID__c, IsBuyer FROM Account WHERE IsBuyer = false AND Oracle_Pricelist_External_ID__c != null AND CreatedDate >= :last24Hours AND RecordTypeId =: devRecordTypeId';
        if(setAccId != null && setAccId.size() > 0){
            query = 'SELECT Id, Name,Oracle_Pricelist_External_ID__c, IsBuyer FROM Account WHERE Id IN:setAccId';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Account> scope) {
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try
        {
            
            Set<String> externalIds = new Set<String>();

            for (Account acc : scope) {
                if (acc.Oracle_Pricelist_External_ID__c != null) {
                    externalIds.add(acc.Oracle_Pricelist_External_ID__c);
                }
            }

            Map<String, String> externalIdToSFId = new Map<String, String>();
            for (Pricebook2 pb : [SELECT Id, Source_External_id__c FROM Pricebook2 WHERE Source_External_id__c IN :externalIds]) {
                externalIdToSFId.put(pb.Source_External_id__c, pb.Id);
            }
            
            Map<String,String> pbIdToBGId = new Map<String,String>();
            for (BuyerGroupPricebook pb : [SELECT BuyerGroupId, PriceBook2Id FROM BuyerGroupPricebook WHERE PriceBook2Id IN :externalIdToSFId.values()]) {
                pbIdToBGId.put(pb.PriceBook2Id, pb.BuyerGroupId);
            }

            
            List<BuyerAccount> lstBA = new List<BuyerAccount>();
            
            for (Account acc : scope) {
                String externalId = acc.Oracle_Pricelist_External_ID__c;
                if(externalIdToSFId.get(externalId) != null && pbIdToBGId.get(externalIdToSFId.get(externalId)) != null){
                    BuyerGroupMember objBGM = new BuyerGroupMember();
                    objBGM.BuyerId = acc.Id;
                    objBGM.BuyerGroupId = pbIdToBGId.get(externalIdToSFId.get(externalId));
                    lstBGM.add(objBGM);
                    
                    BuyerAccount buyrAcc = new BuyerAccount();
                    buyrAcc.Name = acc.Name;
                    buyrAcc.BuyerId = acc.Id;
                    buyrAcc.IsActive = true;
                    lstBA.add(buyrAcc);
                }
            }
            if(!lstBA.isEmpty()){
                database.insert(lstBA,false);
            }
            //if(!lstBGM.isEmpty()){
            //    insert lstBGM;
            //}
        }   
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
    }

    public void finish(Database.BatchableContext BC) {
        B2B_BuyerGroupMemberBatch iterableBatch = new B2B_BuyerGroupMemberBatch(lstBGM);
        Database.executeBatch(iterableBatch, 200);
    }
}