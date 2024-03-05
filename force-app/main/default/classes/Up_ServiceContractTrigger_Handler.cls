public with sharing class Up_ServiceContractTrigger_Handler {
    
    public void OnAfterUpdate(Map<ID, ServiceContract> oldMap, List<ServiceContract> updatedObjects){
        
        set<id> scIds_active = new set<id>();
        set<id> scIds_draft = new set<id>();
        map<id, id> templateToContract_active = new map<id, id>();
        
        map<id, ServiceContract> updateServiceContracts = new map<id, ServiceContract>();
        list<ContractLineItem> updateContractLineItems = new list<ContractLineItem>();
        list<Asset> updateAssets = new list<Asset>();
        list<SM_Service_Contract_Discounts__c> insertSCDiscounts = new list<SM_Service_Contract_Discounts__c>();
        
        for(ServiceContract sc : updatedObjects){
            //status changes
            if(sc.SM_Contract_Status__c != oldMap.get(sc.id).SM_Contract_Status__c){

                //activated
                if(sc.SM_Contract_Status__c == 'Active'){
                    scIds_active.add(sc.id);
                    if(string.isNotEmpty(sc.SM_Service_Contract_Template__c)){
                        //scTemplateIds.add(sc.SM_Service_Contract_Template__c);
                        templateToContract_active.put(sc.SM_Service_Contract_Template__c, sc.id);
                    }                    
                }
                
                //active to draft
                if(sc.SM_Contract_Status__c == 'Draft' && oldMap.get(sc.id).SM_Contract_Status__c == 'Active'){
                    scIds_draft.add(sc.id);
                }
            } 
        }
        
        if(scIds_active.size() > 0 || scIds_draft.size() > 0){
            
            //Get Contract Line Items
            list<ContractLineItem> lineItems = [SELECT Id, ServiceContractId, AssetId, StartDate, EndDate,
                                                Asset.SM_Service_Contract__c, Asset.SM_Future_Service_Contract__c
                                                FROM ContractLineItem
                                                WHERE AssetId != NULL
                                                AND (ServiceContractId IN:scIds_active OR ServiceContractId IN:scIds_draft)];
            
            if(lineItems != null && lineItems.size() > 0){
                for(ContractLineItem li : lineItems){
                    //active
                    if(scIds_active.contains(li.ServiceContractId)){
                        if(li.StartDate <= date.today() && li.EndDate >= date.today()){
                            system.debug(LoggingLevel.ERROR, '* Current SC.');
                            updateAssets.add(new Asset(
                                id = li.AssetId,
                                SM_Service_Contract__c = li.ServiceContractId,
                                SM_Contract_Start_Date__c = li.StartDate,
                                SM_Contract_End_Date__c = li.EndDate
                            )); 
                            updateContractLineItems.add(new ContractLineItem(id = li.id, SM_Activation_Status__c = 'Asset Updated'));
                        }
                        else if(li.StartDate > date.today()){
                            system.debug(LoggingLevel.ERROR, '* Future SC.');
                            updateAssets.add(new Asset(
                                id = li.AssetId,
                                SM_Future_Service_Contract__c = li.ServiceContractId,
                                SM_Future_Contract_Start_Date__c = li.StartDate,
                            	SM_Future_Contract_End_Date__c = li.EndDate
                            ));
                            updateContractLineItems.add(new ContractLineItem(id = li.id, SM_Activation_Status__c = 'Future'));
                        }
                    }
                    
                    //draft
                    if(scIds_draft.contains(li.ServiceContractId)){
                        if(string.isNotEmpty(li.Asset.SM_Service_Contract__c)){
                            updateAssets.add(new Asset(
                                id = li.AssetId,
                                SM_Service_Contract__c = null,
                                SM_Contract_Start_Date__c = null,
                                SM_Contract_End_Date__c = null
                            ));                             
                            
                        }
                        else if(string.isNotEmpty(li.Asset.SM_Future_Service_Contract__c)){
                            updateAssets.add(new Asset(
                                id = li.AssetId,
                                SM_Future_Service_Contract__c = null,
                                SM_Future_Contract_Start_Date__c = null,
                            	SM_Future_Contract_End_Date__c = null
                            ));                            
                        }                        
                        updateContractLineItems.add(new ContractLineItem(id = li.id, SM_Activation_Status__c = ''));
                    }
                }//end li loop
				
                if(updateAssets.size() > 0){
                    system.debug(LoggingLevel.ERROR, '* Update: ' + updateAssets);
                    update updateAssets;
                }
                if(updateContractLineItems.size() > 0){
                    system.debug(LoggingLevel.ERROR, '* Update: ' + updateContractLineItems);
                    update updateContractLineItems;
                }                
            }

            ///get sc discount related to the template and clone.
            if(templateToContract_active.size() > 0){
                list<SM_Service_Contract_Discounts__c> scDiscounts = [SELECT Id, SM_Service_Contract_Discounts__c, SM_Discount__c, CurrencyIsoCode, OwnerId, SM_Product_Type__c
                                                                      FROM SM_Service_Contract_Discounts__c
                                                                      WHERE SM_Service_Contract_Discounts__c IN:templateToContract_active.keySet()];
                if(scDiscounts != null && scDiscounts.size() > 0){
                    for(SM_Service_Contract_Discounts__c scd : scDiscounts){
                        id scId = templateToContract_active.get(scd.SM_Service_Contract_Discounts__c);
                        
                        SM_Service_Contract_Discounts__c clone = scd.clone();
                        clone.SM_Service_Contract__c = scId;
                        clone.SM_Service_Contract_Discounts__c = null;
                        insertSCDiscounts.add(clone);
                        
                        //set flag on sc to true when creating.
                        updateServiceContracts.put(scId, new ServiceContract(id = scId, SM_Discount_Lines_Created__c = true));
                    }
                    
                    
                    if(insertSCDiscounts.size() > 0){
                        system.debug(LoggingLevel.ERROR, '* Insert: ' + insertSCDiscounts);
                        insert insertSCDiscounts;
                    }             
                    
                    if(updateServiceContracts.size() > 0){
                        system.debug(LoggingLevel.ERROR, '* Update: ' + updateServiceContracts.values());
                        update updateServiceContracts.values();
                    }                         
                }
            }
            
            if(scIds_draft.size() > 0){
                list<SM_Service_Contract_Discounts__c> scDiscountsToDelete = [SELECT Id, SM_Service_Contract__c
                                                                              FROM SM_Service_Contract_Discounts__c
                                                                              WHERE SM_Service_Contract__c IN:scIds_draft];
                if(scDiscountsToDelete!= null && scDiscountsToDelete.size() > 0){
                    system.debug(LoggingLevel.ERROR, '* Delete : ' + scDiscountsToDelete);
                    delete scDiscountsToDelete;
                    
                    for(SM_Service_Contract_Discounts__c scd : scDiscountsToDelete){
                        //set flag on sc to false when deleting.
                        id scId = scd.SM_Service_Contract__c;
                        updateServiceContracts.put(scId, new ServiceContract(id = scId, SM_Discount_Lines_Created__c = false));                                            
                    }
                    
                    if(updateServiceContracts.size() > 0){
                        system.debug(LoggingLevel.ERROR, '* Update: ' + updateServiceContracts.values());
                        update updateServiceContracts.values();
                    }                        
                }
            }
        }
    }    
}