public class PricebookTriggerHandler {
    public static void handlePricebookInsert(List<Pricebook2> newPricebooks) {
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            List<BuyerGroup> buyerGroupsToInsert = new List<BuyerGroup>();
            List<CommerceEntitlementPolicy> entitlementPoliciesToInsert = new List<CommerceEntitlementPolicy>();
            List<BuyerGroupPricebook> buyerGroupPricebooksToInsert = new List<BuyerGroupPricebook>();
            List<Webstore> lstStore = [SELECT Id FROM Webstore WHERE Name = 'Zimvie'];
            
            if (lstStore.isEmpty()) {
                return;
            }
            Set<String> setExternalPBId = new Set<String>();
            // Create a map to store the Pricebook2 IDs and their corresponding Buyer Group
            Map<Id, BuyerGroup> pricebookIdToBuyerGroup = new Map<Id, BuyerGroup>();
            Map<BuyerGroupPricebook,buyerGroup> mapBGPBToBG = new Map<BuyerGroupPricebook,buyerGroup>();
            Map<String,CommerceEntitlementPolicy> mapBGToCEP = new Map<String,CommerceEntitlementPolicy>();
            for (Pricebook2 newPricebook : newPricebooks) {
                
                if (newPricebook.Source_External_id__c != null) {
                    BuyerGroup buyerGroup = new BuyerGroup(Name = newPricebook.Name + ' Buyer Group');
                    //buyerGroupsToInsert.add(buyerGroup);
                    pricebookIdToBuyerGroup.put(newPricebook.Id, buyerGroup);
                    
                    CommerceEntitlementPolicy entitlementPolicy = new CommerceEntitlementPolicy(Name = newPricebook.Name + ' Entitlement Policy',IsActive=true,CanViewProduct=true,CanViewPrice=true);
                    //entitlementPoliciesToInsert.add(entitlementPolicy);
                    
                    mapBGToCEP.put(buyerGroup.Name,entitlementPolicy);
                    BuyerGroupPricebook buyerGroupPricebook = new BuyerGroupPricebook(
                        IsActive=true,
                        Pricebook2Id = newPricebook.Id
                    );//BuyerGroup = buyerGroup,
                    //buyerGroupPricebooksToInsert.add(buyerGroupPricebook);
                    mapBGPBToBG.put(buyerGroupPricebook,buyerGroup);
                    setExternalPBId.add(newPricebook.Source_External_id__c);
                }
            }
            Map<String,Id> mapBgToId = new Map<String,Id>();
            
            insert mapBGPBToBG.values();
            for(BuyerGroup bg : mapBGPBToBG.values()){
                mapBgToId.put(bg.Name,bg.Id);
            }
            for(BuyerGroupPricebook buyerGroupPricebook : mapBGPBToBG.keyset()){
                buyerGroupPricebook.BuyerGroupId = mapBGPBToBG.get(buyerGroupPricebook).Id;
                buyerGroupPricebooksToInsert.add(buyerGroupPricebook);
                
            }
            List<CommerceEntitlementBuyerGroup> lstCEBG = new List<CommerceEntitlementBuyerGroup>();
            
            insert mapBGToCEP.values();
            for(String bgName : mapBGToCEP.keyset()){
                CommerceEntitlementBuyerGroup objCEBG = new CommerceEntitlementBuyerGroup();
                objCEBG.BuyerGroupId = mapBgToId.get(bgName);
                objCEBG.PolicyId = mapBGToCEP.get(bgName).Id;
                lstCEBG.add(objCEBG);
            }
            
            insert lstCEBG;
            
            system.debug('buyerGroupPricebooksToInsert='+buyerGroupPricebooksToInsert);
            
            insert buyerGroupPricebooksToInsert;
            
            List<WebStoreBuyerGroup> lstWBG = new List<WebStoreBuyerGroup>();
            //List<WebStorePricebook> lstwbPB = new List<WebStorePricebook>();
            // Use the map created earlier to fetch the corresponding BuyerGroup for each new Pricebook
            for (Pricebook2 newPricebook : newPricebooks) {
                if (newPricebook.Source_External_id__c != null && pricebookIdToBuyerGroup.containsKey(newPricebook.Id)) {
                    BuyerGroup buyerGroup = pricebookIdToBuyerGroup.get(newPricebook.Id);
                    WebStoreBuyerGroup objWBG = new WebStoreBuyerGroup();
                    WebStorePricebook wbPB = new WebStorePricebook();
                    wbPB.Pricebook2Id = newPricebook.Id;
                    wbPB.WebStoreId = lstStore[0].Id;
                    wbPB.IsActive = true;
                    //lstwbPB.add(wbPB);
                    objWBG.BuyerGroupId = buyerGroup.Id;
                    objWBG.WebStoreId = lstStore[0].Id;
                    lstWBG.add(objWBG);
                }
            }
            insert lstWBG;


            Set<Id> setAccId = new Set<Id>();
            Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Ecommerce Account').getRecordTypeId();
            for(Account acc : [Select Id,Oracle_Pricelist_External_ID__c,RecordTypeId from Account where Oracle_Pricelist_External_ID__c IN: setExternalPBId]){
                if(acc.Oracle_Pricelist_External_ID__c != null && acc.RecordTypeId == devRecordTypeId){
                    setAccId.add(acc.Id);
                }
            }
            if(setAccId != null && setAccId.size() > 0){
                B2B_AccountEnablementBatch objBatch = new B2B_AccountEnablementBatch(setAccId);
                database.executebatch(objBatch);
            }
            //insert lstwbPB;
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        
    }
    
    public static void handlePricebookUpdate(List<Pricebook2> updatedPricebooks, Map<Id, Pricebook2> oldPricebooks) {
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            List<BuyerGroup> buyerGroupsToUpdate = new List<BuyerGroup>();
            List<CommerceEntitlementPolicy> entitlementPoliciesToUpdate = new List<CommerceEntitlementPolicy>();
            Map<Id, Id> BuyerGroupIdToPricebookId = new Map<Id, Id>();
            Map<Id, Id> pricebookIdToBuyerGroupId = new Map<Id, Id>();
            Map<Id, Id> PriceBookIdToPolicyId = new Map<Id, Id>();
            
            Set<Id> PBIds = new Set<Id>();
            
            for (Pricebook2 updatedPricebook : updatedPricebooks) {
                Pricebook2 oldPricebook = oldPricebooks.get(updatedPricebook.Id);
                if (updatedPricebook.Name != oldPricebook.Name && updatedPricebook.Source_External_id__c != null) {
                    PBIds.add(updatedPricebook.Id);
                }
            }
            if(PBIds.size() <= 0){
                return;
            }
            Id stdPBId = [select Id from PriceBook2 where IsStandard = True LIMIT 1].Id;
            // Query BuyerGroupPricebook records outside the loop
            for (BuyerGroupPricebook buyerGroupPricebook : [SELECT Id, Pricebook2Id,BuyerGroupId, BuyerGroup.Name FROM BuyerGroupPricebook WHERE Pricebook2Id IN :PBIds LIMIT 1]) {
                pricebookIdToBuyerGroupId.put(buyerGroupPricebook.Pricebook2Id, buyerGroupPricebook.BuyerGroupId);
                BuyerGroupIdToPricebookId.put(buyerGroupPricebook.BuyerGroupId,buyerGroupPricebook.Pricebook2Id);
            }
            
            // Query CommerceEntitlementPolicy records outside the loop
            for (CommerceEntitlementBuyerGroup entitlementPolicyBG : [SELECT PolicyId,BuyerGroupId FROM CommerceEntitlementBuyerGroup WHERE BuyerGroupId IN :BuyerGroupIdToPricebookId.keyset()]) {
                PriceBookIdToPolicyId.put(BuyerGroupIdToPricebookId.get(entitlementPolicyBG.BuyerGroupId),entitlementPolicyBG.PolicyId);
            } 
            
            for (Pricebook2 updatedPricebook : updatedPricebooks) {
                if(updatedPricebook.Id != stdPBId){
                    Id buyerGroupId = pricebookIdToBuyerGroupId.get(updatedPricebook.Id);
                    BuyerGroup buyerGroup = new BuyerGroup(Id = buyerGroupId);
                    buyerGroup.Name = updatedPricebook.Name + ' Buyer Group';
                    buyerGroupsToUpdate.add(buyerGroup);
                    
                    Id policyId = PriceBookIdToPolicyId.get(updatedPricebook.Id);
                    CommerceEntitlementPolicy cep = new CommerceEntitlementPolicy(Id = policyId);
                    cep.Name = updatedPricebook.Name + ' Entitlement Policy';
                    entitlementPoliciesToUpdate.add(cep);
                }
                
            }
            
            update buyerGroupsToUpdate;
            update entitlementPoliciesToUpdate;
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        
        
    }
    
}