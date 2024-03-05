/******************************************************
Description:
Dependancy:
Trigger: Up_WorkOrderTrigger
Test Class: Up_WorkOrderTrigger_Test
Author: Dudu@Uptima.

Modification Log: 
Date                Author          Modification comments
Mar 25, 2021        Dudu            11.12.4. Update asset structure
Mar 29, 2021        Dudu            11.12.4.1 Handle removed child asset
Mar 29, 2021        Dudu            11.11.3 email the service report
Apr 07, 2021        Dudu            11.12.3 Handle Inventory
May 05, 2021        Dudu            Automatically create checklist on work order
Aug 26, 2021        Dudu            Add support for multiple checklist creation per type

 *******************************************************/
public with sharing class Up_WorkOrderTrigger_Handler {
 /*   
    public void OnBeforeUpdate_ServiceReport(Map<ID, WorkOrder> oldMap, List<WorkOrder> updatedObjects){
        
        set<id> woIds = new set<id>();
        set<string> templateIds = new set<string>();
        map<string, id> templateMap = new map<string, id>();
        map<id, Messaging.EmailFileAttachment> woToDoc = new map<id, Messaging.EmailFileAttachment>();
        
        for(WorkOrder wo : updatedObjects){
            system.debug('SM_Email_Service_Report__c: ' + wo.SM_Email_Service_Report__c);
            system.debug('SM_Service_Report_Email_Template__c: ' + wo.SM_Service_Report_Email_Template__c);
            system.debug('ContactId: ' + wo.ContactId);
            if(wo.SM_Email_Service_Report__c != oldMap.get(wo.id).SM_Email_Service_Report__c && wo.SM_Email_Service_Report__c){
                if(string.isNotEmpty(wo.SM_Service_Report_Email_Template__c) && string.isNotEmpty(wo.ContactId)){
                    woIds.add(wo.id);   
                    templateIds.add(wo.SM_Service_Report_Email_Template__c);
                }
            }               
        }
        system.debug('woIds: ' + woIds);
        system.debug('templateIds: ' + templateIds);
        
        if(woIds.size() > 0){
            list<ServiceReport> serviceReports = [SELECT Id, 
                                                  ParentId, 
                                                  ContentVersionDocumentId, 
                                                  ContentVersionDocument.Title,
                                                  ContentVersionDocument.VersionData,
                                                  ContentVersionDocument.FileExtension 
                                                  FROM ServiceReport 
                                                  WHERE ParentId IN:woIds
                                                  ORDER BY ParentId, CreatedDate DESC];
            if(serviceReports != null && serviceReports.size() > 0){
                for(ServiceReport sr : serviceReports){
                    if(!woToDoc.containsKey(sr.ParentId)){
                        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                        attachment.setBody(sr.ContentVersionDocument.VersionData);
                        attachment.setFileName(sr.ContentVersionDocument.Title);
                        attachment.setContentType('application/pdf');
                        woToDoc.put(sr.ParentId, attachment);        
                    }                    
                    
                }
            }
        }
        
        if(templateIds.size() > 0){
            list<EmailTemplate> templates = [SELECT developername, id 
                                             FROM EmailTemplate 
                                             WHERE developername IN :templateIds];
            if(templates != null && templates.size() > 0){
                for(EmailTemplate t : templates){
                    templateMap.put(t.developername, t.id);
                }
            }
        }
        
        
        //send emails.
        for(WorkOrder wo : updatedObjects){
            if(woToDoc.containsKey(wo.id) && templateMap.containsKey(wo.SM_Service_Report_Email_Template__c)){
                sendServiceReport(wo, woToDoc.get(wo.id), templateMap.get(wo.SM_Service_Report_Email_Template__c));
                wo.SM_Email_Service_Report__c = false; //reset flag.
            }               
        }        
    }

    public void OnBeforeUpdate_Checklist(Map<ID, WorkOrder> oldMap, List<WorkOrder> updatedObjects){
        
        set<id> productLineIds = new set<id>();
        set<id> workTypeIds = new set<id>();
        set<string> workOrderTypes = new set<string>();
        list<SM_Checklist__c> insChecklist = new list<SM_Checklist__c>();
        
        map<id, string> woToKey = new map<id,string>();     //map wo id => product line + work type
        map<string, set<string>> recTypeMap = new map<string, set<string>>();
        
        for(WorkOrder wo : updatedObjects){
            if(string.isNotEmpty(wo.AssetId) && string.isEmpty(wo.SM_Checklist_Created__c)){
                if(string.isNotEmpty(wo.SM_Product_Line__c)){
                    
                    wo.SM_Checklist_Created__c = 'No Checklist Found'; //set to not found, will be replaced below if it is.
                    productLineIds.add(wo.SM_Product_Line__c);
                    
                    if(string.isNotEmpty(wo.WorkTypeId)){
                        workTypeIds.add(wo.WorkTypeId);
                        woToKey.put(wo.id, wo.SM_Product_Line__c + '_' + wo.WorkTypeId);
                    }
                    
                    if(string.isNotEmpty(wo.SM_Work_Order_Type__c)){
                        workOrderTypes.add(wo.SM_Work_Order_Type__c);
                        woToKey.put(wo.id, wo.SM_Product_Line__c + '_' + wo.SM_Work_Order_Type__c);
                    }                    
                }
            }
        }   
        
        if(productLineIds.size() > 0){
            list<SM_Product_line_Checklist_Type__c> checklistTypes = [SELECT Id, SM_Checklist_Record_Type_Name__c, SM_Product_Line__c, SM_Work_Type__c, SM_Work_Order_Type__c
                                                                      FROM SM_Product_line_Checklist_Type__c
                                                                      WHERE SM_Product_Line__c IN:productLineIds 
                                                                      AND (SM_Work_Type__c IN:workTypeIds OR SM_Work_Order_Type__c IN:workOrderTypes)];
            if(checklistTypes != null && checklistTypes.size() > 0){
                
                for(SM_Product_line_Checklist_Type__c ct : checklistTypes){
                    string key;
                    if(string.isNotEmpty(ct.SM_Work_Type__c)){
                        key = ct.SM_Product_Line__c.to15() + '_' + ct.SM_Work_Type__c;
                    }
                    else if(string.isNotEmpty(ct.SM_Work_Order_Type__c)){
                        key = ct.SM_Product_Line__c.to15() + '_' + ct.SM_Work_Order_Type__c;
                    }
                    
                    set<string> recordTypes = new set<string>();
                    recordTypes.add(ct.SM_Checklist_Record_Type_Name__c);
                    if(recTypeMap.containsKey(key)){
                        //add existing to the temp set.
                        recordTypes.addAll(recTypeMap.get(key));
                    }
                    recTypeMap.put(key, recordTypes);
                }

                for(WorkOrder wo : updatedObjects){
                    string key;
                    //choose the correct key (there are 2 mapping options).
                    if(string.isNotEmpty(wo.SM_Product_Line__c)){
                        if(string.isNotEmpty(wo.WorkTypeId) && recTypeMap.containsKey(wo.SM_Product_Line__c + '_' + wo.WorkTypeId)){
                            key = wo.SM_Product_Line__c + '_' + wo.WorkTypeId;
                        }
                        else if(string.isNotEmpty(wo.SM_Work_Order_Type__c) && recTypeMap.containsKey(wo.SM_Product_Line__c + '_' + wo.SM_Work_Order_Type__c)){
                            key = wo.SM_Product_Line__c + '_' + wo.SM_Work_Order_Type__c;
                        }
                    }

                    if(recTypeMap.containsKey(key)){
                        set<string> recordTypes = new set<string>();
                        recordTypes.addAll(recTypeMap.get(key));
                        
                        //set wo flag to true, will be false if error in loop.
                        wo.SM_Checklist_Created__c = 'Checklist Created';                          
                        
                        for(string rt : recordTypes){
                            try{
                                id recTypeId = Schema.SObjectType.SM_Checklist__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
                                system.debug('* Rec Type Id: ' + recTypeId);
                                insChecklist.add(new SM_Checklist__c(
                                    Work_Order__c = wo.id,
                                    RecordTypeId = recTypeId
                                ));      
                            }
                            catch (System.NullPointerException e) {
                                system.debug('* No Checklist Found');
                                wo.SM_Checklist_Created__c = 'No Checklist Found'; 
                            }                            
                            
                        }
                    }
                }
                
                if(insChecklist.size() > 0){
                    System.debug('* Insert ' + insChecklist.size() + ' Checklists: ' + insChecklist);
                    insert insChecklist;
                }
            }
        }
    }
   
    public void OnAfterUpdate_WOClose(Map<ID, WorkOrder> oldMap, List<WorkOrder> updatedObjects){
        
        set<id> woIds = new set<id>();
        set<id> productItemsIds = new set<id>();
        set<string> assetKeys = new set<string>();
        map<string, id> keyToAssetId = new map<string, id>();
        list<Asset> upsertAssets = new list<Asset>();
        list<Asset> updateAssets = new list<Asset>();
        list<ProductConsumed> insProductConsumed = new list<ProductConsumed>();
        
        for(WorkOrder wo : updatedObjects){
            if(wo.Status != oldMap.get(wo.id).Status && wo.Status == 'Closed'){
                woIds.add(wo.id);
            }
        }        
        
        //handle asset creation and status remove.
        if(woIds.size() > 0){
            system.debug('* woIds: ' + woIds);
            id consumptionRT = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('SM_Consumption').getRecordTypeId();
            id childAssetRemovedRT = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('SM_Child_Asset_Removed').getRecordTypeId();
            
            list<WorkOrderLineItem> wolis = [SELECT Id, LineItemNumber,
                                             SVMXA360__LineType__c,
                                             RecordTypeId,
                                             AssetId,
                                             Quantity,
                                             SM_Product_Item__c,
                                             SM_Serial_Number_Text__c, 
                                             Product2Id, 
                                             Product2.SM_Asset_Tracked__c,
                                             WorkOrder.SM_Ship_to_Account__c,
                                             WorkOrder.LocationId,
                                             WorkOrder.AccountId,
                                             WorkOrder.AssetId,
                                             WorkOrder.Asset.Status,
                                             WorkOrder.Country,
                                             WorkOrder.SVMXA360__CompletedDate__c
                                             FROM WorkOrderLineItem
                                             WHERE WorkOrderId IN :woIds
                                             AND 
                                             (
                                                 (RecordTypeId = :consumptionRT 
                                                  AND SVMXA360__LineType__c = 'Part' 
                                                  AND Product2.SM_Asset_Tracked__c = true
                                                  AND Product2Id != null
                                                  AND SM_Serial_Number_Text__c != null) 
                                                 OR 
                                                 (RecordTypeId = :childAssetRemovedRT 
                                                  AND AssetId != null)
                                                 OR
                                                 (RecordTypeId = :consumptionRT 
                                                  AND SVMXA360__LineType__c = 'Part'
                                                  AND SM_Product_Item__c != null)
                                             )];
            
            
            if(wolis != null && wolis.size() > 0){
                system.debug('* wolis: ' + wolis);
                for(WorkOrderLineItem woli : wolis){
                    
                    //11.12.3 Handle Inventory
                    if(woli.RecordTypeId == consumptionRT && woli.SVMXA360__LineType__c == 'Part' && woli.SM_Product_Item__c != null){
                        productItemsIds.add(woli.SM_Product_Item__c);
                    }
                    
                    //11.12.4 Trigger - Update asset structure
                    if(woli.RecordTypeId == consumptionRT && woli.SVMXA360__LineType__c == 'Part'  && woli.Product2.SM_Asset_Tracked__c == true){
                        assetKeys.add(woli.Product2Id.to15() + '_' + woli.SM_Serial_Number_Text__c);
                    }
                    
                    //11.12.4.1 Handle removed child asset
                    if(woli.RecordTypeId == childAssetRemovedRT){
                        updateAssets.add(new Asset(
                            id = woli.AssetId,
                            Status = 'Removed'
                        ));
                    }
                }
                
                //11.12.3 Handle Inventory
                if(productItemsIds.size() > 0){
                    map<Id, ProductItem> piMap = new map<id, ProductItem>([SELECT Id, QuantityOnHand
                                                                           FROM ProductItem
                                                                           WHERE Id IN:productItemsIds]);
                    
                    for(WorkOrderLineItem woli : wolis){
                        if(woli.RecordTypeId == consumptionRT && woli.SVMXA360__LineType__c == 'Part' && piMap.containsKey(woli.SM_Product_Item__c)){
                            decimal qtyOnHand = piMap.get(woli.SM_Product_Item__c).QuantityOnHand != null ? piMap.get(woli.SM_Product_Item__c).QuantityOnHand : 0;
                            decimal qtyToDeduct = qtyOnHand < woli.Quantity  ? qtyOnHand : woli.Quantity;
                            
                            system.debug('* woli: ' + woli.LineItemNumber + ' - ' + woli.id);
                            system.debug('* qtyOnHand: ' + qtyOnHand);
                            system.debug('* qtyToDeduct: ' + qtyToDeduct);
                            
                            if(qtyToDeduct > 0){
                                insProductConsumed.add(new ProductConsumed(
                                    WorkOrderLineItemId = woli.id,
                                    WorkOrderId = woli.WorkOrderId,
                                    //Product2Id = woli.Product2Id, //Field is not writeable: ProductConsumed.Product2Id
                                    ProductItemId = woli.SM_Product_Item__c,
                                    QuantityConsumed = qtyToDeduct
                                ));                                
                            }

                        }                        
                    }
                    if(insProductConsumed.size() > 0){
                        system.debug('* Insert Product Consumed: ' + insProductConsumed);
                        insert insProductConsumed;
                    }
                }
                
                //11.12.4. Trigger - Update asset structure
                if(assetKeys.size() > 0){
                    list<Asset> assets = [SELECT Id, SM_Product_SN_Key__c
                                          FROM Asset
                                          WHERE SM_Product_SN_Key__c IN:assetKeys];
                    if(assets != null && assets.size() > 0){
                        for(Asset a : assets){
                            keyToAssetId.put(a.SM_Product_SN_Key__c, a.id);
                        }
                    }
                    
                    for(WorkOrderLineItem woli : wolis){
                        if(woli.RecordTypeId == consumptionRT && woli.SVMXA360__LineType__c == 'Part'  && woli.Product2.SM_Asset_Tracked__c == true){
                            string key = woli.Product2Id.to15() + '_' + woli.SM_Serial_Number_Text__c;
                            system.debug('* key: ' + key);
                            Asset asset = new Asset();
                            if(keyToAssetId.containsKey(key)){
                                asset.id = keyToAssetId.get(key);
                                system.debug('* Existing Asset: ' + asset.id);
                            }
                            else{
                                asset.Name = 'temp';
                            }
                            asset.SerialNumber = woli.SM_Serial_Number_Text__c;
                            asset.Product2Id = woli.Product2Id;
                            asset.AccountId = woli.WorkOrder.AccountId;
                            asset.ParentId = woli.WorkOrder.AssetId;
                            asset.SM_Ship_To_Account__c = woli.WorkOrder.SM_Ship_to_Account__c;
                            asset.LocationId = woli.WorkOrder.LocationId;
                            asset.Status = woli.WorkOrder.Asset.Status;
                            asset.SM_Country__c = woli.WorkOrder.Country;
                            asset.InstallDate = date.valueOf(woli.WorkOrder.SVMXA360__CompletedDate__c);
                            upsertAssets.add(asset);
                        }
                    }
                    
                    if(upsertAssets.size() > 0){
                        system.debug('* Upsert Assets: ' + upsertAssets);
                        upsert upsertAssets;
                    }
                }
                
                //11.12.4.1 Handle removed child asset
                if(updateAssets.size() > 0){
                    system.debug('* Upsert Assets: ' + updateAssets);
                    update updateAssets;
                }
            }
        }
    }    

    public static void sendServiceReport(WorkOrder wo, Messaging.EmailFileAttachment att, id templateId){
        
        system.debug('* templateId: ' + templateId);
        system.debug('* to: ' + wo.SVMXA360__ContactEmail__c);
        system.debug('* cc: ' + wo.SM_CC_Additional_Email__c);
        
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<Messaging.EmailFileAttachment> attList = new List<Messaging.EmailFileAttachment>();
        List<string> toList = new list<string>();
        List<string> ccList = new list<string>();
        
        //mail.setOrgWideEmailAddressId(orgWideId);  
        //mail.setReplyTo(userDetails.get(sp.SM_Work_Order__r.LastModifiedById).Email);
        //mail.setSenderDisplayName(userDetails.get(sp.SM_Work_Order__r.LastModifiedById).FirstName + ' ' + userDetails.get(sp.SM_Work_Order__r.LastModifiedById).LastName);                                                     
        
        toList.add(wo.SVMXA360__ContactEmail__c);
        mail.setToAddresses(toList);
        
        if(string.isNotEmpty(wo.SM_CC_Additional_Email__c)){
            ccList.add(wo.SM_CC_Additional_Email__c);
            mail.setCcAddresses(ccList);            
        }
        
        attList.add(att);
        mail.setSenderDisplayName(UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
        mail.setFileAttachments(attList);
        mail.setTemplateId(templateId);
        mail.setTargetObjectId(wo.ContactId);           //Required if using a template - on custom objects work only with contact id.
        mail.setWhatId(wo.id);                          //ensure that merge fields in the template contain the correct data.
        mail.setTreatTargetObjectAsRecipient(false);    //false, the targetObjectId is supplied as the WhoId field for template 
        mail.setSaveAsActivity(false);                  //false, meaning the email is NOT saved as an activity        
        emailMessageList.add(mail);
        
        System.debug(LoggingLevel.ERROR, '* Email invocations: ' + Limits.getEmailInvocations());
        Messaging.sendEmail(emailMessageList);
        System.debug(LoggingLevel.ERROR, '* Email invocations: ' + Limits.getEmailInvocations());
    }     
  */
}