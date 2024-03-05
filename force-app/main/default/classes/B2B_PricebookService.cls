@RestResource(urlMapping = '/PricebookService/*')
global class B2B_PricebookService {
    @HttpPost
    global static String parseRequest(){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        String message;
        try {
            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;
            List<RequestWrapper> lstrequestWrapper = new List<RequestWrapper>();
            //try{
            lstrequestWrapper = (List<RequestWrapper>)JSON.deserialize(request.requestBody.toString(), List<RequestWrapper>.class);
            
            message= InsertPricebook_Data(lstrequestWrapper);
            system.debug('message::' +message);
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        
        return message;
        //}catch(Exception ex){
        //   system.debug('exception::'+ex);
        //}
    }
    
    private static string InsertPricebook_Data(List<RequestWrapper> lstrequestWrapper){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        string status;
        try {
            Set<String> setUniqueId = new Set<String>();
        for(RequestWrapper req: lstrequestWrapper){
            setUniqueId.add(req.externalId);
        }
        List<PriceBookEntry> lstPBEToDelete = new List<PriceBookEntry>();
        Map<Id,PriceBook2> mapExistingPB = new Map<Id,PriceBook2>([Select Id,OracleUniqueId__c from Pricebook2 where OracleUniqueId__c IN:setUniqueId]);
        Map<String,Id> mapUniqueIdtoSfId = new Map<String,Id>();
        for(PriceBook2 objpb : mapExistingPB.values()){
            mapUniqueIdtoSfId.put(objpb.OracleUniqueId__c,objpb.Id);
        }
        lstPBEToDelete = [SELECT Id FROM PriceBookEntry WHERE PriceBook2Id IN: mapExistingPB.keyset()];
        if(!lstPBEToDelete.isEmpty()){
            delete lstPBEToDelete;
        }
        List<PriceBook2> lstPB = new List<PriceBook2>();
        List<PriceBookEntry> lstPBE = new List<PriceBookEntry>();
        for(RequestWrapper req: lstrequestWrapper){
            Pricebook2 objPB			=	new Pricebook2();
            objPB.Name					=	req.name;
            objPB.OracleUniqueId__c		=	req.externalId;
            objPB.IsActive				=	true;
            if(mapUniqueIdtoSfId.keyset().contains(objPB.OracleUniqueId__c)){
                objPB.Id				=	mapUniqueIdtoSfId.get(objPB.OracleUniqueId__c);
            }
            lstPB.add(objPB);
            for(pbeData objChildData : req.entries){
                PriceBookEntry objPBE = new PriceBookEntry();
                objPBE.Product2Id = objChildData.ProductId;
                objPBE.PriceBook2 = new PriceBook2(OracleUniqueId__c=req.externalId);
                objPBE.IsActive = true;
                objPBE.UnitPrice = objChildData.price; 
                lstPBE.add(objPBE);
            }
        }
        
        //try {
        upsert lstPB;
        Set<Id> setCurrentPBId = new Set<Id>();
        for(Pricebook2 objPB : lstPB){
            setCurrentPBId.add(objPB.Id);
        }
        List<PriceBookEntry> lstStandardPBE = new List<PriceBookEntry>();
        Pricebook2 stndrdPB = [select Id, Name, IsActive from PriceBook2 where IsStandard=True LIMIT 1];
        for(PriceBookEntry objPBE2 : lstPBE){
            PriceBookEntry objStandardPBE = new PriceBookEntry();
            objStandardPBE.Product2Id = objPBE2.Product2Id;
            objStandardPBE.PriceBook2Id = stndrdPB.Id;
            objStandardPBE.IsActive = true;
            objStandardPBE.UnitPrice = objPBE2.UnitPrice; 
            lstStandardPBE.add(objStandardPBE);
        }
        database.insert(lstStandardPBE,false);
        insert lstPBE;
        system.debug(lstPBE);
        Set<Id> setPBEId = new Set<Id>();
        for(PriceBookEntry objPBE : lstPBE){
            setPBEId.add(objPBE.Id);
        }
        
        List<PriceBookEntry> lstPBENew = new List<PriceBookEntry>();
        lstPBENew = [Select Id,Product2Id,PriceBook2Id from PriceBookEntry where Id IN:setPBEId];
        
        Map<Id,List<Id>> mapPBToProducts = new Map<Id,List<Id>>();
        for(PriceBookEntry objpbe : lstPBENew){
            if(!mapPBToProducts.keyset().contains(objpbe.PriceBook2Id)){
                mapPBToProducts.put(objpbe.PriceBook2Id,new List<Id>());
            }
            mapPBToProducts.get(objpbe.PriceBook2Id).add(objpbe.Product2Id);
        }
        system.debug('mapPBToProducts='+mapPBToProducts);
        List<BuyerGroupPricebook> lstBgpb = new List<BuyerGroupPricebook>();
        lstBgpb = [Select Id,BuyerGroupId,Pricebook2Id from BuyerGroupPricebook where Pricebook2Id IN: setCurrentPBId];//mapPBToProducts.keyset()];
        
        Map<Id,Id> mapPBIdToBgId = new Map<Id,Id>();
        Map<Id,Id> mapBgIdToPolicyId = new Map<Id,Id>();
        
        for(BuyerGroupPricebook objBgpb : lstBgpb){
            mapPBIdToBgId.put(objBgpb.Pricebook2Id,objBgpb.BuyerGroupId);
        }
        
        List<CommerceEntitlementBuyerGroup> lstCebg = new List<CommerceEntitlementBuyerGroup>();
        lstCebg = [Select PolicyId,BuyerGroupId from CommerceEntitlementBuyerGroup where BuyerGroupId IN:mapPBIdToBgId.values()];
        for(CommerceEntitlementBuyerGroup objCebg : lstCebg){
            mapBgIdToPolicyId.put(objCebg.BuyerGroupId,objCebg.PolicyId);
        }
        system.debug('mapBgIdToPolicyId='+mapBgIdToPolicyId);
        system.debug('mapPBIdToBgId='+mapPBIdToBgId);
        delete [Select Id from CommerceEntitlementProduct where PolicyId IN:mapBgIdToPolicyId.values()];
        List<CommerceEntitlementProduct> lstCEPToInsert = new List<CommerceEntitlementProduct>();
        if(mapPBToProducts != null  && mapPBToProducts.size() > 0){
            for(Id pbId : mapPBToProducts.keyset()){
                for(Id prodId : mapPBToProducts.get(pbId)){
                    CommerceEntitlementProduct objCEP = new CommerceEntitlementProduct();
                    objCEP.ProductId = prodId;
                    objCEP.PolicyId = mapBgIdToPolicyId.get(mapPBIdToBgId.get(pbId));
                    lstCEPToInsert.add(objCEP);
                }
            }  
        }
        if(!Test.isRunningTest())
        insert lstCEPToInsert;
        status = 'Inserted successfully';
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        
        
        /////
        //} catch (DmlException e) {
        //    system.debug('Exception ::' +e.getMessage());
        //    return 'Error Details: ' + e.getMessage();
        //}
        return status;
    }
    public class RequestWrapper {
        public String name;
        public String externalId;
        public List<pbeData> entries;        
    }
    public class pbeData {
        public String productId;
        public Decimal price;
        public String externalid;
    }
}