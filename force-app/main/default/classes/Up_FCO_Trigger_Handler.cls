public with sharing class Up_FCO_Trigger_Handler {
    
    private set<id> fcoIds;
    private list<SM_FCO__c> fcoToProcess;
    private map<id, ContentVersion> fcoToDocMap; 	//cfo.id to the version(w/ blob)
    private set<id> assetIds;
    private map<id, Asset> assetMap;
    private string errorLabel;
    
    public Up_FCO_Trigger_Handler(){
        this.fcoIds = new set<id>();
        this.fcoToProcess = new list<SM_FCO__c>();
        this.assetIds = new set<id>();
    }
    
    /**
    * This is the method to be called within triggers.
    * @param new FCO's
    * @param old FCO's map
    * @return void.
    **/ 
    public void OnBeforeUpdate(Map<ID, SM_FCO__c> oldMap, List<SM_FCO__c> updatedObjects){
        
        for(SM_FCO__c fco : updatedObjects){
            if(fco.SM_Create_FCO_Lines__c){
                this.fcoIds.add(fco.id);
                this.fcoToProcess.add(fco);
            }
        }
        getAndMapData();
        commitData();
    }
    
    private void getAndMapData(){
        if (this.fcoToProcess.isEmpty()) {
            return;
        }
        
        //Query CSV attachment
        if(this.fcoIds.size() > 0){

            //Get Doc Links using FCO Ids. 
            //Obj.Id -> COntentDocumentLink.LinkedEntityId
            list<ContentDocumentLink> docLinkList = [SELECT Id, LinkedEntityId, ContentDocumentId
                                                     FROM ContentDocumentLink
                                                     WHERE LinkedEntityId IN:this.fcoIds
                                                     AND ContentDocument.FileType = 'CSV'];            
            system.debug('* docLinkList: ' + docLinkList);
            if(docLinkList != null && docLinkList.size() > 0){
                map<id, id> contentDoctoFCO = new map<id, id>();	//contentDoc.id to cfo.id
                for(ContentDocumentLink cdl : docLinkList){
                    contentDoctoFCO.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                }
                
                //Get Doc Version(Blob) for Content Doc ids.
                list<ContentVersion> docVersionList = [SELECT Id, VersionData, ContentDocumentId
                                                       FROM ContentVersion
                                                       WHERE ContentDocumentId IN:contentDoctoFCO.keySet()
                                                       AND IsLatest = true];     
                system.debug('* docVersionList: ' + docVersionList);
                
                if(docVersionList != null && docVersionList.size() > 0){
                    this.fcoToDocMap = new map<id, ContentVersion>();
                    for(ContentVersion cv : docVersionList){
                        id fco = contentDoctoFCO.get(cv.ContentDocumentId);	//get fco id
                        this.fcoToDocMap.put(fco, cv);
                        system.debug('* FCO: ' + fco + ' -> ContentVersion: ' + cv.id);
                    }
                }
            }
        }
    }    
    
    private void commitData(){
        
        list<SM_Applicable_FCO__c> applicableFCOToInsert = new list<SM_Applicable_FCO__c>();
        
        for(SM_FCO__c fco : this.fcoToProcess){
            fco.SM_Create_FCO_Lines__c = false;	//uncheck flag.
            if(this.fcoToDocMap != null && this.fcoToDocMap.containsKey(fco.id)){
                //In Process
                fco.SM_Create_FCO_Lines_Status__c = label.SM_FCO_Lbl_Process;
                
                blob bCSV = this.fcoToDocMap.get(fco.id).VersionData;
                string sCSV = bCSV.toString();
                getAssets(sCSV);
                
                if(this.errorLabel.length() > 0){
                    fco.SM_Create_FCO_Lines_Status__c = this.errorLabel;
                    continue;
                }
                
                if(this.assetIds.size() > 0){
                    for(id aId : this.assetIds){
                        applicableFCOToInsert.add(new SM_Applicable_FCO__c(
                            //Name = fco.Name + '_' + this.assetMap.get(aId).Name,
                            SM_FCO__c = fco.id,
                            SM_Asset__c = aId,
                            SM_Status__c = 'Pending',
                            SM_FCO_Kit__c = fco.SM_FCO_Kit__c
                        ));                            
                    }
                    
                    String template = label.SM_FCO_Lbl_Success;
                    List<Object> parameters = new List<Object> {this.assetIds.size()};
                    String formatted = String.format(template, parameters);
                    fco.SM_Create_FCO_Lines_Status__c = formatted;
                }
            }
            else{
                //CSV file is not found
                fco.SM_Create_FCO_Lines_Status__c = label.SM_FCO_Lbl_Error1;
            }
        }       
        
        if(applicableFCOToInsert.size() > 0){
            system.debug('* Insert Applicable FCO: ' + applicableFCOToInsert);
            insert applicableFCOToInsert;
        }
    }
    
    private void getAssets(string sCSV){
        this.errorLabel = '';
        list<string> lstCSV = sCSV.split('\n');
        list<list<string>> cleanCSV = new list<list<string>>();
        system.debug('* CSV = ' + sCSV);
        
        if(!sCSV.remove('"').startsWithIgnoreCase('Asset ID')){
            //Asset ID column is not found
            this.errorLabel = label.SM_FCO_Lbl_Error3;
            return;
        }
        
        for(string s: lstCSV){
            string aId = s.split(',')[0];
            system.debug('* Asset = ' + aId);
            
            //Clean " and '
            if(aId.containsAny('"\'')){
                aId = aId.remove('"').remove('\'');
            }
            
            //Check if ID format.
            if((aId.length() == 15 || aId.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', aId)) {
                this.assetIds.add(aId);
            }
        }           
        
        if(this.assetIds.size() > 0){
            //Get Assets using ids.
            this.assetMap = new map<id, Asset>([SELECT Id, Name 
                                                FROM Asset
                                                WHERE Id IN:this.assetIds]);                  
        }
        else{
            //Asset ID column is not found
            this.errorLabel = label.SM_FCO_Lbl_Error2;
        }
    }
}