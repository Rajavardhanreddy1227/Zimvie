public with sharing class BPSurgeonSelectionController {
    public BPSurgeonSelectionController() {

    }
    @AuraEnabled 
    public static List<accountListWrapper> fetchAccountWrapper(ID businessplanID
                                                                , String productgroupName
                                                                ,String sortField
                                                                , boolean isAsc
                                                                , String filter
                                                                , String segment ){     
        List<accountListWrapper> lstaccountListWrapper = new List<accountListWrapper>();
        // query account records and create 'accountListWrapper' class instance for each record. 
        List < Market_Segmentation__c > lstMktSeg = new List<Market_Segmentation__c>();
        system.debug('Business Plan ID'+ businessplanID);
        system.debug('productgroupName'+ productgroupName);
        system.debug('sortField'+ sortField);
        system.debug('isAsc'+ isAsc);
        system.debug('filter'+ filter);
        system.debug('segment'+ segment);
        
        Business_plan__c bp = [select id,Territory_Account_Name__c,Territory_Account_Name__r.RVP__c,Territory_Account_Name__r.RVP__r.FirstName,
                               					Territory_Account_Name__r.RVP__r.LastName from Business_plan__c where id = :businessplanID Limit 1];
         
		system.debug('--------AVP----'+bp.Territory_Account_Name__r.RVP__c);
		system.debug('--------AVP-fstName---'+bp.Territory_Account_Name__r.RVP__r.FirstName);
		system.debug('--------AVP-fstName---'+bp.Territory_Account_Name__r.RVP__r.LastName);
                                                                    
		string strAvp = bp.Territory_Account_Name__r.RVP__r.FirstName + ' '+bp.Territory_Account_Name__r.RVP__r.LastName;

        Set<ID> BPExistingSurgeonIdSet = new Set<ID>();
        String  rectypeName;
        rectypeName = productgroupName == 'Hips' ? 'US Hip' 
                        : productgroupName == 'Knees'? 'US Knee' 
                        : productgroupName == 'Sports Medicine' ? 'US Sports Medicine'  
                        : productgroupName == 'Extremities' ? 'US Extremities'  
                        : productgroupName == 'Foot & Ankle' ? 'US Foot and Ankle' 
                        : productgroupName == 'Trauma' ? 'US Trauma' 
                        : productgroupName == 'Cement' ? 'US Cement' 
                        : ''; 
        if(rectypeName != null || rectypeName != ''){
            for(Opportunity Opp  : [SELECT id, Surgeon_Name__c, Product_Sales_Summary__r.Business_Plan__c, recordType.Name
                                    FROM Opportunity 
                                    WHERE   Product_Sales_Summary__r.Business_Plan__c = :bp.id
                                    AND    recordType.Name = :rectypeName ]){
                BPExistingSurgeonIdSet.add(Opp.Surgeon_Name__c);                            
            }
        }
        string territoryaccountId = bp.Territory_Account_Name__c ; 
        String sSoql = 'SELECT ID, Surgeon_Name__c , Surgeon_Name__r.name , Aligned_Team__c, Surgeon_Name__r.PersonMailingStreet, Surgeon_Name__r.PersonMailingCity, Surgeon_Name__r.PersonMailingState, Master_Territory__c, Master_Territory_ID__c , Segementation__c, Product_Group__c, Market_Procedures__c, Zimmer_Biomet_Procedures__c, Procedure_Opportunity__c';
        sSoql += ' From Market_Segmentation__c WHERE Master_Territory_ID__c = :territoryaccountId ';
        If(filter!= null && filter != ''){
            String tempInput ='\'%' + filter  + '%\'';
            sSoql += ' AND Surgeon_Name__r.name LIKE ' +tempInput;
        }
        If(segment!= null && segment != ''){          
            sSoql += ' AND Segementation__c = :segment ';
        }
        If(productgroupName != null ){
            sSoql += ' AND Product_Group__c = :productgroupName ';
        }  
        /*
        IF(BPExistingSurgeonIdSet.size() > 0 ){
             sSoql += ' AND Surgeon_Name__c NOT IN :BPExistingSurgeonIdSet ';
        }   */
        system.debug('Surgeon_Name__c BPExistingSurgeonIdSet ' + BPExistingSurgeonIdSet);       
        if (sortField != '') {
            sSoql += ' order by ' + sortField;
        
            // if isAsc is equal tp ture then set 'asc' order otherwise set 'desc' order.
                if (isAsc) {
                    sSoql += ' asc';
                } else {
                    sSoql += ' desc';
                }
        }       
        list <Market_Segmentation__c> lstResult;
        try {
            system.debug('The query is' + sSoql);
            lstResult = Database.query(sSoql);
    
            for (Market_Segmentation__c mkt: lstResult) {
                
                lstaccountListWrapper.add(new accountListWrapper(false,BPExistingSurgeonIdSet.contains(mkt.Surgeon_Name__c)? true : false,mkt.Surgeon_Name__r.name.toUpperCase(),mkt,strAvp));
            }
            return lstaccountListWrapper;
        } 
        catch (Exception ex) {
            // for handle Exception
            return null;
        }        
    }
    
    /* wrapper class */  
    public class accountListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public boolean bptarget {get;set;}
        @AuraEnabled public String SurgeonName {get;set;}
        @AuraEnabled public  Market_Segmentation__c objAccount{get;set;}
        @AuraEnabled public String avpName {get;set;}
        public accountListWrapper(boolean isChecked, boolean bptarget, String SurgeonName, Market_Segmentation__c objAccount, String avpName){
            this.isChecked = isChecked;
            this.bptarget = bptarget;
            this.SurgeonName = SurgeonName;
            this.objAccount = objAccount;
            this.avpName = avpName;
        }
    }


    @AuraEnabled
    public static List < String > createOpportunities(List < Market_Segmentation__c > lstRecord, String businessplanID) {
        // for store Error Messages  
        List < String > oErrorMsg = new List < String > ();
        system.debug('Market Segmentation recrods --- >>>>> '+lstRecord);
        // Query Records for delete where id in lstRecordId [which is pass from client side controller] 
        Map<String, String> MaprecTypeNameID = new Map<String, String>();
        for(RecordType rectype : [SELECT Id,DeveloperName,SobjectType,Name FROM RecordType WHERE SobjectType = 'Opportunity']){
            String  rectypeName;
            rectypeName = rectype.name == 'US Hip' ? 'Hips' 
                            : rectype.name == 'US Knee' ? 'Knees'
                            : rectype.name == 'US Sports Medicine' ? 'Sports Medicine'
                            : rectype.name == 'US Extremities' ? 'Extremities'
                            : rectype.name == 'US Foot and Ankle' ? 'Foot & Ankle'
                            : rectype.name == 'US Trauma' ? 'Trauma'
                            : rectype.name == 'US Cement' ? 'Cement'
                            : 'NA'; 
            
            MaprecTypeNameID.put(rectypeName, rectype.id);
        }
        Map<String,String> prodsalessumNameID = new Map<String,String>();
        for(Product_Sales_Summary__c prod : [SELECT id, Business_Plan__c, Product_Group__c from Product_Sales_Summary__c where Business_Plan__c =:businessplanID]){
                prodsalessumNameID.put(prod.Product_Group__c, prod.id);
        }
        List<Opportunity> CreateOpp = new List<Opportunity>(); 
        for(Market_Segmentation__c mkt : lstRecord){
            if(mkt.Surgeon_Name__c != null && MaprecTypeNameID.containsKey(mkt.Product_Group__c) && prodsalessumNameID.containsKey(mkt.Product_Group__c)){
                Opportunity tempOpp = new Opportunity ();
                    tempOpp.Name = mkt.Surgeon_Name__r.name; 
                    tempOpp.Surgeon_Name__c =  mkt.Surgeon_Name__c; 
                    tempOpp.CloseDate = Date.newInstance(System.Today().year(), 12, 31);
                    tempOpp.stageName = 'Discover'; 
                    tempOpp.recordTypeId = MaprecTypeNameID.get(mkt.Product_Group__c);
                    tempOpp.Product_Sales_Summary__c = prodsalessumNameID.get(mkt.Product_Group__c);
                    tempOpp.Team_Name__c = mkt.Aligned_Team__c ; 
                    tempOpp.Avalanche_Segmentation__c = mkt.Segementation__c ; 
                    tempOpp.BP_Target__c = TRUE; 
                CreateOpp.add(tempOpp);
            }        
        }

        Database.SaveResult[]  DR_svs = Database.insert(CreateOpp, false);
        // Iterate through each returned result
        for (Database.SaveResult dr: DR_svs) {
            if (dr.isSuccess()) {
                system.debug('successful added in the business plan');
                // Operation was successful
            } else {
                // Operation failed, so get all errors   
                oErrorMsg.add('');
                for (Database.Error err: dr.getErrors()) {
                    // add Error message to oErrorMsg list and return the list
                    oErrorMsg.add(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
        return oErrorMsg;

    }
}