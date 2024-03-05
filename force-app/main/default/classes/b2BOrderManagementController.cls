public class b2BOrderManagementController {
    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.RMA_E_Return);
    @AuraEnabled
    public static String validateandSaveReturnOrder(String jsonOfListOfOrders){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            List<OrderItemWrapper> listOfOrders = (List<OrderItemWrapper>) JSON.deserialize(jsonOfListOfOrders, List<OrderItemWrapper>.class);
            errorWrapper objWrap = new errorWrapper();
            objWrap.orderIdErrorSet = new Set<String>();
            //objWrap.orderIdErrorSet = new Set<String>();
            //objWrap.orderIdErrorSet = new Set<String>();
            //objWrap.orderIdErrorSet = new Set<String>();
            //objWrap.orderIdErrorSet = new Set<String>();
            // return 'Insert Successfully';
            return JSON.serialize(listOfOrders);
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return null;
    }
    public class errorWrapper {
        public Set<String> orderIdErrorSet;
        public Set<String> orderIdDateErrorSet;
        public Set<String> qtyErrorSet;
        public Set<String> expDateErrorSet;
        public Set<String> lotNoErrorSet;
    }
    public class OrderItemWrapper {
        public String item;
        public String quantity;
        public String lot;
        public String expiryDate;
        public String order;
        public String invoice;
        public String resell;
        public String comments;
        public String reorderItem;
        public String reorderQuantity;    
    }
    
    public class customerInputOrderItemWrapper {
        public String item;
        public String quantity;
        public String lot;
        public String expiryDate;
        public String order;
        public String invoice;
        public Boolean resell;
        public String comments;
        public String returnReason;
        public String shipToId;
    }
    @AuraEnabled(cacheable=true)
    public static String getUserDetails(String userId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            //Added by deepak Account.AccountNumber,Account.Oracle_Operating_Unit__c
            return JSON.serialize([select id,Contact.Name,ContactId,AccountId,Account.Name, Country,Account.AccountNumber,Account.Oracle_Operating_Unit__c,Account.BillingCountry from User where Id=:userId]);
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return null;
    }
    
    @AuraEnabled
    public static Map<String,Object> validateandSaveRMADetails(Map<String,Object> mapParams){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            RMA__c obj=new RMA__c();
            string cartType;
            string cartId;
            //Added By Deepak
            Integer CounterRecordId=0;
            RMA__c rmaObj=new RMA__c();
            Map<string,customerInputOrderItemWrapper> OrderItemWrapperMap=new Map<string,customerInputOrderItemWrapper>();
            set<string> orderIdsFromOracleResponse=new set<string>();
            Map<String,String> oracleOrderNumberToOrderId=new Map<String,String>();
            Map<String,String> oracleOrderNumberToOrderSummaryId=new Map<String,String>();
            List<b2BOracleCalloutController.oracleLotValidationRequestWrapper> oracleLotValidationRequestWrapper=new List<b2BOracleCalloutController.oracleLotValidationRequestWrapper>();   
            List<Object> filterValuesforLotValidation=(List<Object>)mapParams.get('filterList');
            List<RMA_Item__c> objRMALineItems = new List<RMA_Item__c>();
            for(Object objNew:filterValuesforLotValidation ){
                CounterRecordId += 1;
                //Creating Oracle request Payload
                b2BOracleCalloutController.oracleLotValidationRequestWrapper ORW=new b2BOracleCalloutController.oracleLotValidationRequestWrapper();
                Map<Object,Object> str=(Map<Object,Object>)objNew;
                ORW.OrgId=(String)mapParams.get('OrgId');
                ORW.LotNumber=(String)str.get('Lot');
                ORW.ItemNumber=(String)str.get('ItemSku');
                ORW.AccountNumber=(String)mapParams.get('AccountNumber');
                ORW.SiteUseId=(String)str.get('OracaleAddressId');
                ORW.RecordId=string.valueof(CounterRecordId);
                oracleLotValidationRequestWrapper.add(ORW);
                
                //Putting the field vales entered by User from form
                customerInputOrderItemWrapper CIOIW=new customerInputOrderItemWrapper();
                CIOIW.Item=(String)str.get('Item');
                CIOIW.lot=(String)str.get('Lot');
                CIOIW.quantity=(string)str.get('Quantity');
                CIOIW.resell=(Boolean)str.get('Resell');
                CIOIW.invoice=str.containsKey('Invoice')?(String)str.get('Invoice'):'';
                CIOIW.returnReason=((String)mapParams.get('RMAType')=='Return' && str.containsKey('Return'))?(String)str.get('Return'):'';
                CIOIW.comments=(str.containsKey('Comments'))?(String)str.get('Comments'):'';
                CIOIW.shipToId=(string)str.get('ShipAddressId');
                OrderItemWrapperMap.put(string.valueof(CounterRecordId),CIOIW);
            }
            List<b2BOracleCalloutController.oracleLotValidationResponseWrapper> OracleResponse=b2BOracleCalloutController.OracleLotValidation(JSON.serialize(oracleLotValidationRequestWrapper));
            for(b2BOracleCalloutController.oracleLotValidationResponseWrapper ORW:OracleResponse){
                if(ORW.ErrorMessage!=''){
                    return null;
                }else{
                    orderIdsFromOracleResponse.add(ORW.OrderNumber);
                }
            }
            List<OrderSummary> orderSummaries=[select Id,OriginalOrderId, OracleOrderId__c from OrderSummary where OracleOrderId__c in:orderIdsFromOracleResponse];
            List<ContactPointAddress> ContactPointAddress=[select Id,Name,Country from ContactPointAddress where ParentId=:(String)mapParams.get('accId') AND AddressType='Billing' limit 1];
            for(OrderSummary OS:orderSummaries){
                oracleOrderNumberToOrderId.put(OS.OracleOrderId__c,OS.OriginalOrderId);
                oracleOrderNumberToOrderSummaryId.put(OS.OracleOrderId__c,OS.Id);
            }
            rmaObj.RMA_Order_Type__c=(ContactPointAddress.size()>0 && ContactPointAddress[0].Country!=null && ContactPointAddress[0].Country!='')?String.valueof(B2B_Billing_Country_To_RMAOrderType__mdt.getInstance(ContactPointAddress[0].Country.replaceAll(' ','_')).RMA_Order_Type__c):'';
            rmaObj.AccountId__c=(String)mapParams.get('accId');
            rmaObj.Bill_to_Contact__c=(String)mapParams.get('contactId');
            rmaObj.Raised_By__c=(String)mapParams.get('userId');
            rmaObj.RMA_TYPE__c=(String)mapParams.get('RMAType');
            //rmaObj.Ship_To_Address__c=(String)mapParams.get('ShipAddressId');
            if((String)mapParams.get('RMAType')=='Return'){
                rmaObj.Status__c='Submitted';
            }else if((String)mapParams.get('RMAType')!='Return'){
                rmaObj.Status__c='Draft';
            }	
            
            insert rmaObj;
            for(b2BOracleCalloutController.oracleLotValidationResponseWrapper ORW:OracleResponse){
                
                RMA_Item__c rmaItem=new RMA_Item__c();
                //Oracle Response fields
                rmaItem.Order_Number__c=ORW.OrderNumber;
                rmaItem.Order_Type__c=ORW.OrderType;
                rmaItem.Shipped_Date__c=Date.valueOf(ORW.ShippedDate);
                rmaItem.Line_Number__c=ORW.LineNumber;
                rmaItem.Price_List__c=ORW.PriceList;
                rmaItem.Item_Number__c=ORW.ItemNumber;
                rmaItem.Expiry_Date__c=Date.valueof(ORW.LotExpiryDate);
                rmaItem.Manual_Adjustment_Flag__c=ORW.DiscountFlag=='N'?false:true;
                rmaItem.Order_Summary__c=oracleOrderNumberToOrderSummaryId.get(ORW.OrderNumber);
                rmaItem.Order_Id__c=oracleOrderNumberToOrderId.get(ORW.OrderNumber);
                
                //Customer Input
                rmaItem.RMAId__c=rmaObj.id;
                rmaItem.Lot_Shipped_Qty__c=ORW.LotShipQuantity;
                rmaItem.Total_Previous_Qty__c=ORW.PreviousRMAQuantity; 
                rmaItem.Return_Product__c=OrderItemWrapperMap.get(ORW.RecordId).item;
                rmaItem.Return_Quantity__c=Decimal.valueof(OrderItemWrapperMap.get(ORW.RecordId).quantity);
                rmaItem.Lot__c=OrderItemWrapperMap.get(ORW.RecordId).lot;
                rmaItem.n_Reselleable_Condition__c =OrderItemWrapperMap.get(ORW.RecordId).resell;
                rmaItem.Invoice__c=OrderItemWrapperMap.get(ORW.RecordId).invoice;
                rmaItem.Return_Reason__c=OrderItemWrapperMap.get(ORW.RecordId).returnReason;
                rmaItem.Comments__c=OrderItemWrapperMap.get(ORW.RecordId).comments;
                rmaItem.Ship_to_address__c=OrderItemWrapperMap.get(ORW.RecordId).shipToId;
                objRMALineItems.add(rmaItem);
                
            }
            //Ended Deepak Changes
            system.debug('====='+objRMALineItems);
            List<RMA_Item__c> objRMALineItem = new List<RMA_Item__c>();
            
            obj.AccountId__c=(String)mapParams.get('accId');
            obj.Bill_to_Contact__c=(String)mapParams.get('contactId');
            obj.Raised_By__c=(String)mapParams.get('userId');
            obj.RMA_TYPE__c=(String)mapParams.get('RMAType');
            if((String)mapParams.get('RMAType')=='Return'){
                obj.Status__c='Submitted';
            }else if((String)mapParams.get('RMAType')!='Return'){
                obj.Status__c='Draft';
            }
            // insert obj;
            mapParams.put('RMA Id',rmaObj.Id);
            //mapParams.put('RMA Id',obj.Id);
            mapParams.put(B2BConstants.IS_SUCCESS,true);
            system.debug('MapFilterList Loop'+mapParams.get('filterList'));  
            List<Object> filterValues=(List<Object>)mapParams.get('filterList');
            for(Object objNew:filterValues ){
                Map<Object,Object> str=(Map<Object,Object>)objNew;
                system.debug('InnerListItem Loop'+str);
                RMA_Item__c rmaItem=new RMA_Item__c();
                system.debug('Accouunt Number'+(String)str.get('ItemSku'));
                rmaItem.Return_Product__c=(String)str.get('Item');
                rmaItem.Return_Quantity__c=Integer.valueOf(str.get('Quantity'));
                if((String)mapParams.get('RMAType')=='Return'){
                    system.debug('ReturnReason'+ str.get('Return'));
                    if(str.containsKey('Return')){
                        rmaItem.Return_Reason__c=(String)str.get('Return');
                    }
                }
                // rmaItem.Return_Reason__c=(String)str.get('Return');
                if(str.containsKey('Invoice')){
                    rmaItem.Invoice__c=(String)str.get('Invoice');
                }else{
                    rmaItem.Invoice__c='';
                }
                rmaItem.Lot__c=(String)str.get('Lot');
                if(str.containsKey('Resell')){
                    rmaItem.n_Reselleable_Condition__c=Boolean.valueOf(str.get('Resell'));
                }
                String tempStr = String.valueof(str.get('Expirydate'));
                String[] dateComponents = tempStr.split('-'); 
                Integer year = Integer.valueOf(dateComponents[0]); 
                Integer month = Integer.valueOf(dateComponents[1]); 
                Integer day = Integer.valueOf(dateComponents[2]); 
                Date myDate = date.newinstance(year , month , day);
                rmaItem.Expiry_Date__c=myDate;
                if(str.containsKey('Comments')){
                    rmaItem.Comments__c=(String)str.get('Comments');
                }else{
                    rmaItem.Comments__c='';
                }
                //rmaItem.Comments__c=(String)str.get('Comments');
                rmaItem.RMAId__c=obj.Id;
                if(str.containsKey('OrderId')){
                    rmaItem.Order_Id__c=(String)str.get('OrderId');
                }
                if((String)mapParams.get('RMAType')=='Exchange'){
                    if(str.containsKey('ReturnReason')){
                        rmaItem.Exchange_Reason__c=(String)str.get('ReturnReason');
                    }
                    if(str.containsKey('ReorderItem')){
                        rmaItem.Exchange_Product__c=(String)str.get('ReorderItem');
                    }else{
                        rmaItem.Exchange_Product__c='';
                    }
                    if(str.containsKey('ReorderQuantity')){
                        rmaItem.Exchange_Quantity__c=Integer.valueOf(str.get('ReorderQuantity'));
                    }  
                    rmaItem.Cart__c=(String)mapParams.get('cartId');
                    cartId=(String)mapParams.get('cartId');
                    cartType='RMA-ExchangeCart';
                }
                if((String)mapParams.get('RMAType')=='Courtesy'){
                    if(str.containsKey('ReturnReasonCourtsey')){
                        rmaItem.Replacement_reason__c=(String)str.get('ReturnReasonCourtsey');
                    }
                    if(str.containsKey('ReorderItem')){
                        rmaItem.Exchange_Product__c=(String)str.get('ReorderItem');
                    }else{
                        rmaItem.Exchange_Product__c='';
                    }
                    if(str.containsKey('ReorderQuantity')){
                        rmaItem.Exchange_Quantity__c=Integer.valueOf(str.get('ReorderQuantity'));
                    }  
                    if(str.containsKey('PatientId')){
                        rmaItem.Patient_Id__c=(String)str.get('PatientId');
                    }  
                    rmaItem.Cart__c=(String)mapParams.get('cartId');
                    
                    String eventDate = String.valueof(str.get('EventDate'));
                    String[] dateComponents1 = eventDate.split('-'); 
                    Integer year1 = Integer.valueOf(dateComponents1[0]); 
                    Integer month1 = Integer.valueOf(dateComponents1[1]); 
                    Integer day1 = Integer.valueOf(dateComponents1[2]); 
                    Date myDate1 = date.newinstance(year1 , month1 , day1);
                    rmaItem.Event_Date__c=myDate1;
                    cartType='RMA-CourtesyCart';
                    cartId=(String)mapParams.get('cartId');
                }
                system.debug('objRMALineItem'+rmaItem);
                objRMALineItem.add(rmaItem);
                
            }
            // insert objRMALineItem;
            insert objRMALineItems;
            if((String)mapParams.get('RMAType')!='Return'){
                WebCart fFod = new WebCart(
                    Id = cartId,
                    Type__c = cartType
                );
                update fFod;
            }
            mapParams.put(B2BConstants.IS_SUCCESS,true);
        }
        catch(exception e){
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(B2BConstants.IS_SUCCESS,false);
            mapParams.put(B2BConstants.MESSAGE,e.getMessage());
            logger.error(e);
            system.debug(''+e.getlinenumber());
            system.debug(''+e.getmessage());
            
        }
        finally{
            logger.flush();
        }
        return mapParams;
    }
    
    @AuraEnabled
    public static Map<String,String> getShipmentDetails(String accId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            Map<String,String> str = new Map<String,String>();
            List<ShipmentItem> shipItem= ([select Lot__c,OrderItemSummary.OrderSummary.OriginalOrderId,OrderItemSummary.OrderSummary.Order_Number__c from ShipmentItem where OrderItemSummary.OrderSummary.AccountId=:'0018L00000GssWnQAJ']);
            
            for(ShipmentItem objNew:shipItem ){
                str.put(objNew.Lot__c, objNew.OrderItemSummary.OrderSummary.OriginalOrderId+'-'+objNew.OrderItemSummary.OrderSummary.Order_Number__c);
            }
            return str;
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return null;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getProductDetails(String prodSKU){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            // return JSON.serialize([select Name from Product2 Where StockKeepingUnit =:prodSKU]);
            
            Map<String,String> str = new Map<String,String>();
            List<Product2> prodItem= ([select Id,Name,StockKeepingUnit  from Product2 where StockKeepingUnit !=null ]);
            
            for(Product2 objNew:prodItem ){
                str.put(objNew.StockKeepingUnit, objNew.Id+'-'+objNew.Name);
            }
            return str;
        }   
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return null;
    }
    
    @AuraEnabled
    public static void addItemsToCartApex(Map<String,String> mapProdIds)
    {   
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            system.debug('mapProdIds='+mapProdIds);
            //try {
            //addItemToCart(webstoreId, effectiveAccountId, activeCartOrId, cartItemInput)
            String effectiveAccountId = [Select Contact.AccountId from User where Id =: UserInfo.getUserId()].Contact.AccountId;
            // Lookup the webstore ID associated with the community
            String storeId = [Select Id from Webstore where Name = 'ZimVie'].Id;
            
            List<ConnectApi.BatchInput> batchList = new List<ConnectApi.BatchInput>();
            
            for(String prodId  : mapProdIds.keyset()){
                ConnectApi.CartItemInput objCInput = new ConnectApi.CartItemInput();
                objCInput.productId = prodId;
                objCInput.quantity = mapProdIds.get(prodId);
                
                //objCInput.type = new ConnectApi.​CartItemType();
                //ConnectApi.BatchInput objBI = new ConnectApi.BatchInput();
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(objCInput);
                //objBI.input = objCInput;
                batchList.add(batchInput);
            }
            
            // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceWishlist_static_methods.htm#apex_ConnectAPI_CommerceWishlist_static_methods
            ConnectApi.CommerceCart.addItemsToCart(storeId,effectiveAccountId,'current',batchList);
            //}
            //catch (Exception ex) {
            //    logger.error(ex);
            //} finally {
            //    logger.flush();
            //}
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        
        
    }
    //Added by Deepak
    @AuraEnabled
    public static String getShipToAddressDetails(String AddressId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            return JSON.serialize([select Id,Name,Street,City,State,PostalCode,Country from ContactPointAddress where id=:AddressId limit 1]);
            
        }catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return null;
    }
    
    @AuraEnabled
    public static Map<String,Object> getLotValidationAPIReponse(Map<String,Object> mapParams){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        List<b2BOracleCalloutController.oracleLotValidationRequestWrapper> oracleLotValidationRequestWrapper=new List<b2BOracleCalloutController.oracleLotValidationRequestWrapper>();   
        Map<String,String> ReturnMap=new Map<String,String>();
        try {
            b2BOracleCalloutController.oracleLotValidationRequestWrapper ORW=new b2BOracleCalloutController.oracleLotValidationRequestWrapper();
            ORW.OrgId=(String)mapParams.get('OrgId');
            ORW.LotNumber=(String)mapParams.get('Lot');
            ORW.ItemNumber=(String)mapParams.get('ItemSku');
            ORW.AccountNumber=(String)mapParams.get('AccountNumber');
            ORW.SiteUseId=(String)mapParams.get('OracaleAddressId');
            ORW.RmaQuantity=(String)mapParams.get('RmaQuantity');
            oracleLotValidationRequestWrapper.add(ORW);
            List<b2BOracleCalloutController.oracleLotValidationResponseWrapper> OracleResponse=b2BOracleCalloutController.OracleLotValidation(JSON.serialize(oracleLotValidationRequestWrapper));            
            if(OracleResponse!=null && OracleResponse.size()>0){
                if(OracleResponse[0].ErrorMessage==''){
                    ReturnMap.put('Success',JSON.serialize(OracleResponse[0]));
                }else{
                    ReturnMap.put('Error',OracleResponse[0].ErrorMessage);
                }
            }else{
                ReturnMap.put('Error','Something went wrong.');
            }
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return ReturnMap;
    }
    
    @AuraEnabled
    public static Map<String,String> saveRmaAndRmaLine(List<Object> rmaAndRmaLine){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        List<b2BOracleCalloutController.oracleLotValidationRequestWrapper> oracleLotValidationRequestWrapper=new List<b2BOracleCalloutController.oracleLotValidationRequestWrapper>();
        set<string> orderIdsFromOracleResponse=new set<string>();
        Map<String,String> oracleOrderNumberToOrderId=new Map<String,String>();
        Map<String,String> oracleOrderNumberToOrderSummaryId=new Map<String,String>();
        List<RMA_Item__c> objRMALineItems = new List<RMA_Item__c>();
        Map<String,String> ReturnMap=new Map<String,String>();
        string accountId;
        try {
            for (Object RMALine : rmaAndRmaLine)
            {
                Map<Object,Object> RMALineObject=(Map<Object,Object>)RMALine;
                orderIdsFromOracleResponse.add((String)RMALineObject.get('OrderNumber'));
                accountId=(String)RMALineObject.get('accountId');
            }
            List<OrderSummary> orderSummaries=[select Id,OriginalOrderId, OracleOrderId__c from OrderSummary where OracleOrderId__c in:orderIdsFromOracleResponse];
            for(OrderSummary OS:orderSummaries){
                oracleOrderNumberToOrderId.put(OS.OracleOrderId__c,OS.OriginalOrderId);
                oracleOrderNumberToOrderSummaryId.put(OS.OracleOrderId__c,OS.Id);
            }
            //Creating RMA and Gettinh Id;
            String rmaId=saveRma(rmaAndRmaLine,accountId);
            
            //Looping through RMA Lines
            for (Object RMALine : rmaAndRmaLine)
            {
                Map<Object,Object> RMALineObject=(Map<Object,Object>)RMALine;
                RMA_Item__c rmaItem=new RMA_Item__c();
                //Oracle Response fields
                rmaItem.Order_Number__c=(String)RMALineObject.get('OrderNumber');
                rmaItem.Order_Type__c=(String)RMALineObject.get('OrderType');
                rmaItem.Shipped_Date__c=Date.Valueof(String.Valueof(RMALineObject.get('ShippedDate')));
                rmaItem.Line_Number__c=Integer.valueOf(RMALineObject.get('LineNumber'));
                rmaItem.Price_List__c=(String)RMALineObject.get('PriceList');
                rmaItem.Item_Number__c=(String)RMALineObject.get('ItemNumber');
                rmaItem.Manual_Adjustment_Flag__c=(String)RMALineObject.get('DiscountFlag')=='N'?false:true;
                rmaItem.Order_Summary__c=oracleOrderNumberToOrderSummaryId.get((String)RMALineObject.get('OrderNumber'));
                rmaItem.Order_Id__c=oracleOrderNumberToOrderId.get((String)RMALineObject.get('OrderNumber'));
                //Customer Input
                rmaItem.RMAId__c=rmaId;
                rmaItem.Expiry_Date__c=Date.valueof(String.Valueof(RMALineObject.get('LotExpiryDate')));
                rmaItem.Lot_Shipped_Qty__c=Integer.Valueof(RMALineObject.get('LotShipQuantity'));
                rmaItem.Total_Previous_Qty__c=Integer.Valueof(RMALineObject.get('PreviousRMAQuantity')); 
                rmaItem.Return_Product__c=(String)RMALineObject.get('Item');
                rmaItem.Return_Quantity__c=Integer.Valueof(RMALineObject.get('quantity'));
                rmaItem.Lot__c=(String)RMALineObject.get('lotNumber');// for Reponse oracleLotNumber
                rmaItem.n_Reselleable_Condition__c =(String)RMALineObject.get('resaleCondition')=='Yes'?True:False;
                rmaItem.Invoice__c=(String)RMALineObject.get('Invoice');
                rmaItem.Return_Reason__c=(String)RMALineObject.get('returnReson');
                rmaItem.Comments__c=(String)RMALineObject.get('Comments');
                rmaItem.Ship_to_address__c=(String)RMALineObject.get('ShipAddressId');
                objRMALineItems.add(rmaItem);   
            }
            if(!objRMALineItems.isEmpty()){
                insert objRMALineItems;
                ReturnMap.put('Success','RMA Line Success');
                return ReturnMap;
            }
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return null;
    }
    
    public static String saveRma(List<Object> rma,String accountId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        RMA__c rmaObj=new RMA__c();
        try {
            if(rma!=null && !rma.isEmpty()){
                Map<Object,Object> rmaObject=(Map<Object,Object>)rma[0];
                List<ContactPointAddress> ContactPointAddress=[select Id,Name,Country from ContactPointAddress where ParentId=:accountId AND AddressType='Billing' limit 1];
                rmaObj.RMA_Order_Type__c=(ContactPointAddress.size()>0 && ContactPointAddress[0].Country!=null && ContactPointAddress[0].Country!='')?String.valueof(B2B_Billing_Country_To_RMAOrderType__mdt.getInstance(ContactPointAddress[0].Country.replaceAll(' ','_')).RMA_Order_Type__c):'';
                rmaObj.AccountId__c=(String)rmaObject.get('accountId');
                rmaObj.Bill_to_Contact__c=(String)rmaObject.get('contactId');
                rmaObj.Raised_By__c=(String)rmaObject.get('userId');
                rmaObj.RMA_TYPE__c=(String)rmaObject.get('RMAType');
                rmaObj.Ship_To_Address__c=(String)rmaObject.get('ShipAddressId');
                if((String)rmaObject.get('RMAType')=='Return'){
                    rmaObj.Status__c='Submitted';
                }else if((String)rmaObject.get('RMAType')!='Return'){
                    rmaObj.Status__c='Draft';
                }
                insert rmaObj;
                return rmaObj.id;
            }
            
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return null;
    }
    @AuraEnabled(cacheable=true)
    public static String getProductMerchandizingDetails(String itemId,String bCountry){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
         return JSON.serialize([select  Name, Product__c, Product_Name__c, Segment_2__c, Segment_1__c, Segment_3__c, Segment_4__c, Segment_5__c, Segment_6__c, Is_Returnable_or_Exchangeable__c,
                               Is_Complaint_Replacement__c, Return_Days_for_US_CA__c, Return_Days_for_EMEA__c, Exchange_Days_for_US_CA__c, Exchange_Days_for_EMEA__c from RMA_Product_Merchandizing__c 
                               where Product__c='01t5f000002tyulAAA' AND Segment_1__c=:bCountry]);
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return null;
    }
}