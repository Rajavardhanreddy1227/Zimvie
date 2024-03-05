public class b2B_checkoutAddressController {

    private static B2B_Oracle_Settings__mdt oraclePricingApi = B2B_Oracle_Settings__mdt.getInstance('Oracle_Pricing_Api_endpoint');

    @AuraEnabled
    public static void updateAddressOnCDG(String Id,String DeliverToCity,String DeliverToCountryCode,String DeliverToPostalCode,String DeliverToStateCode,String DeliverToStreet,String DeliverToName, String cpaId, String commId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            ContactPointAddress cpa =[SELECT Id, ORAAddressId__c, ParentId FROM ContactPointAddress WHERE Id = :cpaId LIMIT 1];
        if(cpa.ORAAddressId__c != NUll ){
            ConnectApi.CartSummary cartSummObj = RSM_CartController.getCartSummaryLWR(commId, Null, Null);
            String cartId;
            if(test.isRunningTest()){
                cartId = [SELECT Id FROM WebCart LIMIT 1]?.Id;
            }
            else{
            	cartId = cartSummObj.cartId;
}
            WebCart cartObj = [SELECT Id, Selected_Contact_Point_Address__c FROM WebCart WHERE Id = :cartId LIMIT 1];
            cartObj.Selected_Contact_Point_Address__c = cpa.Id;
            update cartObj;
        }else{
            //get Oracle Id from integration.
            B2B_AddressValidationController.getOracleIdAndStore(DeliverToCity, DeliverToCountryCode, DeliverToStateCode, DeliverToPostalCode, DeliverToStreet, cpa.ParentId, DeliverToName, commId, cpaId);
        }

        CartDeliveryGroup deliverGroup = new CartDeliveryGroup();

        deliverGroup.Id = Id;
        deliverGroup.DeliverToCity = DeliverToCity;
        deliverGroup.DeliverToCountryCode = DeliverToCountryCode;
        deliverGroup.DeliverToPostalCode = DeliverToPostalCode;
        deliverGroup.DeliverToStateCode = DeliverToStateCode;
        deliverGroup.DeliverToStreet = DeliverToStreet;
        deliverGroup.DeliverToName = DeliverToName;

        update deliverGroup;
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        
    }   
    @AuraEnabled
    public static String callShippingIntegration(Id cartId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            return B2b_ShippingMethod.findShippingMethodByCountry([Select DeliverToCountry,CartId from CartDeliveryGroup where CartId=:cartId order by CreatedDate desc limit 1]);
        }   
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return null;
        //Id cartId = [Select DeliverToCountry,CartId from CartDeliveryGroup where Id=:CdgId].CartId;
        //B2BShipmentZimVie objCls = new B2BShipmentZimVie();
        //objCls.startCartProcessAsync(new sfdc_checkout.IntegrationInfo(),cartId,DeliverToCountry);
        
    }

    @AuraEnabled
    public static Map<String,Object> callTaxIntegrationCustom(Id inputCartId){
        Map<String,Object> resp = new Map<String,Object>();
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            //Id cartId = [Select DeliverToCountry,CartId from CartDeliveryGroup where Id=:CdgId].CartId;
        B2BTaxZimVie objCls = new B2BTaxZimVie();
        //objCls.startCartProcessAsync(new sfdc_checkout.IntegrationInfo(),inputCartId);startCustomTaxIntegration
        resp = objCls.startCustomTaxIntegration(inputCartId); 
        //return B2b_ShippingMethod.findShippingMethodByCountry([Select DeliverToCountry,CartId from CartDeliveryGroup where Id=:CdgId]);
        }
        catch(exception e){
            resp.put('isSuccess', false);
            resp.put('Error',e);
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return resp;
    }
    @AuraEnabled
    public static string getCDGID(String cartId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            return [Select Id from CartDeliveryGroup where CartId=:cartId order by createddate desc limit 1].Id;
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
    public static List<CartDeliveryGroupMethod> fetchOrderDeliveryMethods(List<String> lstOrderMethodId,String cdgId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            return [Select DeliveryMethodId,DeliveryMethod.Name,ShippingFee,currencyIsoCode from CartDeliveryGroupMethod where DeliveryMethodId IN:lstOrderMethodId AND CartDeliveryGroupId=:cdgId];
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
    public static Map<String,Object> getShippingDiscount(Map<String,Object> inputMap){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        Map<String,Object> resp = new Map<String,Object>();
        
        try {
            ConnectApi.CartSummary cartSummObj = RSM_CartController.getCartSummaryLWR(String.valueOf(inputMap.get('commId')), Null, Null);
            String cartId = cartSummObj.cartId;
            resp = makeApiCallout(cartId);
        } catch (Exception e) {
            resp.put('Error', e);
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return resp;
    }

    @AuraEnabled
    public static Map<String,Object> ifOrcaleAddId(Map<String,Object> inputMap){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        Map<String,Object> resp = new Map<String,Object>();
        logger.debug('inputMap--'+JSON.serialize(inputMap));
        try {
            if(inputMap.containsKey('cpaId')){
                String cpaId = (String)inputMap.get('cpaId');
                logger.debug('cpaId--'+JSON.serialize(cpaId));
                ContactPointAddress cpa = [SELECT ORAAddressId__c, City, CountryCode, StateCode, PostalCode, Street, ParentId, Name, /*commId, */Id FROM ContactPointAddress WHERE Id = :cpaId LIMIT 1];
                logger.debug('cpa--'+JSON.serialize(cpa));
                if(cpa.ORAAddressId__c == NULL){
                    resp.put('Oracle Integration called', true);
                    String commId = String.valueOf(inputMap.get('commId'));
                    resp = B2B_AddressValidationController.getOracleIdAndStore(cpa.City, cpa.CountryCode, cpa.StateCode, cpa.PostalCode, cpa.Street, cpa.ParentId, cpa.Name, commId, cpa.Id);
                    logger.debug('integration resp--'+JSON.serialize(resp));
                }else{
                    resp.put('Oracle Integration called', false);
                    resp.put('oracleAddId',cpa.ORAAddressId__c);
                }
            }else{
                resp.put('Error', 'invalid cpaId');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }finally{
            logger.flush();
        }
        return resp;
    }

    @AuraEnabled
    public static Map<String,Object> checkoutOrderSummaryData(Map<String,Object> inputMap){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        Map<String,Object> resp = new Map<String,Object>();
        Boolean success = false;
        try {
            String cartId = (String)inputMap.get('cartId');
            List<CartItem> cartitems = [
                SELECT Id,sku, cartId, Product2Id, Product2.Name, Quantity, TotalAdjustmentAmount, TotalAmount, TotalListPrice, TotalPrice, 
                Type, unitAdjustedPrice, unitAdjustmentAmount, AdjustmentAmount, ListPrice, SalesPrice, TotalLineAmount,
                Cart.TotalProductAmount, Cart.TotalPromoAdjustmentAmount, Cart.TotalChargeAmount, Cart.TotalTaxAmount, Cart.GrandTotalAmount, Cart.TotalAdjustmentAmount,
                Cart.TotalListAmount, TotalLineNetAmount, TotalTaxAmount,CurrencyIsoCode
                FROM CartItem
                WHERE cartId = :cartId
            ];
            orderSummaryResponseWrapper wrap = new orderSummaryResponseWrapper();
            for(CartItem ci : cartitems){
                System.debug('summaryData ci---- '+ci);
                if(ci.Type == 'Product'){
                    wrap.OrderSubtotal = wrap.OrderSubtotal + ci.TotalLineNetAmount;
                    wrap.DiscountAdjustments = wrap.DiscountAdjustments - ci.TotalAdjustmentAmount; //negative
                    wrap.Tax = wrap.Tax + ci.TotalTaxAmount;
                }else if(ci.Type == 'Charge'){
                    wrap.Shipping = wrap.Shipping + ci.TotalLineNetAmount;
                    wrap.ShippingDiscount = wrap.ShippingDiscount - (ci.TotalAdjustmentAmount == null ? 0 : ci.TotalAdjustmentAmount);
                    wrap.ShippingTax = wrap.ShippingTax + ci.TotalTaxAmount;
                }
                if(ci.sku=='TBHF'){
                    wrap.TissueHandlingFee = ci.TotalLineNetAmount;
                    wrap.OrderSubtotal = wrap.OrderSubtotal - ci.TotalLineNetAmount;
                }
                wrap.currencyCode = ci.CurrencyIsoCode;
                //wrap.Total = 0;
            }
            success = true;
            // wrap.DiscountAdjustments = wrap.DiscountAdjustments * -1;
            // wrap.ShippingDiscount = wrap.ShippingDiscount * -1;
            wrap.DummyTotal = wrap.OrderSubtotal + wrap.TissueHandlingFee - wrap.DiscountAdjustments;
            wrap.Total = wrap.OrderSubtotal + wrap.Tax + wrap.Shipping + wrap.ShippingTax + wrap.TissueHandlingFee - wrap.ShippingDiscount - wrap.DiscountAdjustments;
            
            System.debug('summaryData---- '+wrap);
            resp.put('summaryData', wrap);
            resp.put('success', success);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }finally{

            logger.flush();
        }
        return resp;
    }

    public static void updateShippingCartItem(String cartId, Decimal discountAmount){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            discountAmount = discountAmount.setScale(2);
        if(discountAmount <= 0){
            CartItem cartItemToUpdate = [SELECT Id, AdjustmentAmount, AdjustmentTaxAmount, GrossAdjustmentAmount, NetAdjustmentAmount, TotalPrice,
                                        TotalAdjustmentAmount, TotalPriceAfterAllAdjustments, TotalLineAmount, UnitAdjustedPrice, UnitAdjustmentAmount, 
                                        cart.GrandTotalAmount, TotalPromoAdjustmentAmount, Quantity, SalesPrice, CartId
                                        FROM CartItem where CartId =: cartId AND Type = 'Charge' LIMIT 1];
            cartItemToUpdate.AdjustmentAmount = discountAmount;
            //cartItemToUpdate.AdjustmentTaxAmount          //to do UnitAdjustmentAmount, UnitAdjustedPrice
            cartItemToUpdate.TotalAdjustmentAmount = discountAmount;
            cartItemToUpdate.TotalPriceAfterAllAdjustments = cartItemToUpdate.TotalLineAmount + discountAmount;
            cartItemToUpdate.TotalPrice = cartItemToUpdate.TotalLineAmount + discountAmount;
            //cartItemToUpdate.TotalPromoAdjustmentAmount = discountAmount;     //removing this because this was doubling the discount value on cart.
            //cartItemToUpdate.UnitAdjustmentAmount = discountAmount/cartItemToUpdate.Quantity;
            update cartItemToUpdate;
        }
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        
    } 

    public static Map<String,Object> makeApiCallout(string inputCartId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        Map<String,Object> resp = new Map<String,Object>();
        try {
            
        //String endpointUrl = 'https://dev-ecomm.zimvie.com/ords/psp_datahub/datahub/ecmprice';
        String endpointUrl = oraclePricingApi.key__c;
        String xmlRequestBody = generateXMLBody(inputCartId);
        HttpRequest request = new HttpRequest();
        request.setTimeout(60000);
        //request.setTimeout(10);
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/xml');
        request.setBody(xmlRequestBody);

        HttpResponse response = new Http().send(request);
        System.debug('response---- '+response);
        System.debug('responseBody---- '+response.getBody());
        if (response.getStatusCode() == 200) {
            String xmlResponse = response.getBody();
            // Parse the XML
            Dom.Document doc = new Dom.Document();
            doc.load(xmlResponse);

            // Create a wrapper object
            WrapperObject wrapperObj = new WrapperObject();

            // Parse PricingResult
            Dom.XmlNode pricingResultNode = doc.getRootElement();
            wrapperObj.PricingResult = new PricingResult();

            // Parse RequestResult
            Dom.XmlNode requestResultNode = pricingResultNode.getChildElement('RequestResult', null);
            wrapperObj.PricingResult.RequestResult = new RequestResult();
            wrapperObj.PricingResult.RequestResult.Status = requestResultNode.getChildElement('Status', null).getText();
            wrapperObj.PricingResult.RequestResult.Message = requestResultNode.getChildElement('Message', null).getText();

            // Parse OrderHeader
            Dom.XmlNode orderHeaderNode = pricingResultNode.getChildElement('OrderHeader', null);
            wrapperObj.PricingResult.OrderHeader = new OrderHeader();
            wrapperObj.PricingResult.OrderHeader.HeaderID = orderHeaderNode.getAttribute('HeaderID',null);
            wrapperObj.PricingResult.OrderHeader.CurrencyCode = orderHeaderNode.getChildElement('CurrencyCode', null).getText();
            Dom.XmlNode discountedShipChargeNode = orderHeaderNode.getChildElement('DiscountedShippingCharge', null);
            if(discountedShipChargeNode != null){
                wrapperObj.PricingResult.OrderHeader.DiscountedShippingCharge = Decimal.valueOf(orderHeaderNode.getChildElement('DiscountedShippingCharge', null).getText());
            }
            Dom.XmlNode ShiptoLocationNode = orderHeaderNode.getChildElement('ShiptoLocation', null);
            wrapperObj.PricingResult.OrderHeader.ERPReferenceID = Decimal.valueOf(ShiptoLocationNode.getChildElement('ERPReferenceID', null).getText());
            // List<Dom.XmlNode> ShiptoLocationNodes = orderHeaderNode.getChildElement('ShiptoLocation', null).getChildElements();
            // for(Dom.XmlNode ShiptoLocNode :ShiptoLocationNodes){
            //     wrapperObj.PricingResult.OrderHeader.ERPReferenceID = Decimal.valueOf(ShiptoLocNode.getChildElement('ERPReferenceID', null).getText());
            // }

            // Parse OrderLines
            List<Dom.XmlNode> orderLineNodes = pricingResultNode.getChildElement('OrderLines', null).getChildElements();
            wrapperObj.PricingResult.OrderLines = new List<OrderLine>();
            for (Dom.XmlNode orderLineNode : orderLineNodes) {
                OrderLine orderLine = new OrderLine();
                orderLine.LineID = orderLineNode.getAttribute('LineID',null);
                orderLine.PricedQuantity = Decimal.valueOf(orderLineNode.getChildElement('PricedQuantity', null).getText());
                orderLine.PricedListPrice = Decimal.valueOf(orderLineNode.getChildElement('PricedListPrice', null).getText());
                orderLine.PricedSellingPrice = Decimal.valueOf(orderLineNode.getChildElement('PricedSellingPrice', null).getText());

                // Parse Discounts
                Dom.XmlNode discountXmlNode = orderLineNode.getChildElement('Discounts', null);
                if(discountXmlNode != null){
                    List<Dom.XmlNode> discountNodes = orderLineNode.getChildElement('Discounts', null).getChildElements();
                    orderLine.Discounts = new List<Discount>();
                    for (Dom.XmlNode discountNode : discountNodes) {
                        Discount discount = new Discount();
                        discount.DiscountID = discountNode.getAttribute('DiscountID',null);
                        discount.DiscountName = discountNode.getChildElement('DiscountName', null).getText();
                        discount.DiscountedAmount = Decimal.valueOf(discountNode.getChildElement('DiscountedAmount', null).getText());
                        discount.DiscountedPercent = Decimal.valueOf(discountNode.getChildElement('DiscountedPercent', null).getText());
                        orderLine.Discounts.add(discount);
                    }
                }
                wrapperObj.PricingResult.OrderLines.add(orderLine);
                system.debug('wrapperObj==='+JSON.serialize(wrapperObj));
                resp.put('PricingResult', JSON.serialize(wrapperObj));
                resp.put('cartId',inputCartId);
                resp.put('isSuccess', true);
                if(wrapperObj?.PricingResult?.OrderHeader?.DiscountedShippingCharge != null){
                    Decimal discountAmnt = (wrapperObj?.PricingResult?.OrderHeader?.DiscountedShippingCharge) * -1;
                    resp.put('discountAmnt', String.valueOf(discountAmnt));
                    updateShippingCartItem(inputCartId, discountAmnt);
                }else{
                    Decimal discountAmnt = 0;
                    resp.put('discountAmnt', String.valueOf(discountAmnt));
                    resp.put('no discount in Oracle', String.valueOf(discountAmnt));
                    updateShippingCartItem(inputCartId, discountAmnt);
                }
            }
        }
        else{
            //retry api callout
            //System.enqueueJob(new B2B_OracleShippingDiscount_Retry(xmlRequestBody, endpointUrl, inputCartId));
            String xmlErrorResponse = response.getBody();
            Map<String, Object> resultMap = XMLParser.xmlToMap(xmlErrorResponse);
            Map<String, Object> pricingResultMap = (Map<String, Object>) resultMap.get('PricingResult');
            String errorMessage = 'API callout failed with status code: ' + response.getStatusCode();
            resp.put('discountCalloutError', errorMessage);
            resp.put('errorResponse',pricingResultMap);
        }
        }
        catch(exception e){
            resp.put('isSuccess', false);
            resp.put('Error',e);
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        
        return resp;
    }

    public static String generateXMLBody(String cartId){ 
        String randomGUID = (String) ((Map<String,Object>) JSON.deserializeUntyped(new Auth.JWT().toJSONString())).get('jti');
        //String itemId = cartItemId;
        String accId;
        List<CartItem> cartItemToUpdate = [SELECT Id, Cart.AccountId, CartDeliveryGroup.DeliverToName, CurrencyIsoCode, Product2.Source_External_id__c, 
                                        Product2.ProductCode, Quantity, Product2.Unit_Measure__c, UnitAdjustedPrice, CartId, ListPrice, Type, SalesPrice, 
                                        Cart.Selected_Contact_Point_Address__c
                                        FROM CartItem where CartId = :cartId AND Type = 'Product'];
        CartItem chargeItem = [SELECT Id, UnitAdjustedPrice, CartId, ListPrice, Type
                                FROM CartItem where CartId = :cartId AND Type = 'Charge' LIMIT 1];
        ContactPointAddress cpa = [SELECT Id, Name, Country, PostalCode, State, City, Street, ParentId, AddressType, ORAAddressId__c 
                                    FROM ContactPointAddress 
                                    WHERE Id =: cartItemToUpdate[0].Cart.Selected_Contact_Point_Address__c];
        accId = cartItemToUpdate[0].Cart.accountId;
        Account acc = [SELECT Id, Oracle_Account_Number__c, Oracle_Address_ID__c FROM Account WHERE Id =: accId LIMIT 1];
        // List<ContactPointAddress> cpaList = [SELECT Id, Name, Country, PostalCode, State, City, Street, ParentId, AddressType, ORAAddressId__c 
        //                                     FROM ContactPointAddress 
        //                                     WHERE ParentId =: accId AND AddressType = 'Shipping' AND ORAAddressId__c != Null];

        CartDeliveryGroup cdg = [SELECT Id, CartId, DeliveryMethodId, DeliveryMethod.Carrier, DeliveryMethod.ClassOfService,
                                    DeliverToStreet, DeliverToCity, DeliverToStateCode, DeliverToPostalCode, DeliverToCountryCode, DeliverToName  
                                    FROM CartDeliveryGroup WHERE CartId = :cartId LIMIT 1];
        //CartDeliveryGroupMethod odm = [SELECT DeliveryMethodId,DeliveryMethod.Name,ShippingFee,currencyIsoCode FROM CartDeliveryGroupMethod WHERE DeliveryMethodId IN:lstOrderMethodId];
        String nickName = cdg.DeliverToName;
        nickName = nickName.replace('&', 'and');
        string strxml ='';
        strxml ='<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
                    '<PricingRequest TrackingGUID="' + randomGUID + '">' +  
                        '<OrderHeader HeaderID="' + cartId + '">' +                //'<OrderHeader HeaderID="184019">' +
                            '<OrderNumber>' + cartId + '</OrderNumber>' +          //'<OrderNumber>184019</OrderNumber>' +
                            '<CustomerID>' + acc.Oracle_Account_Number__c + '</CustomerID>' +                                     //'<CustomerID>417054</CustomerID>' + 
                            '<CustomerNumber>' + acc.Oracle_Account_Number__c + '</CustomerNumber>' +                             //'<CustomerNumber>418762</CustomerNumber>' +
                            '<ShiptoName/>' +
                            //'<ShippingCarrier>FedEx</ShippingCarrier>' +
                            '<ShippingCarrier>'+ cdg.DeliveryMethod.Carrier +'</ShippingCarrier>' +
                            '<CarrierService>'+ cdg.DeliveryMethod.ClassOfService +'</CarrierService>' +
                            '<ShippingCharge>'+ chargeItem.ListPrice +'</ShippingCharge>' +
                            '<CurrencyCode>USD</CurrencyCode>';
                            if(cpa.ORAAddressId__c != null){
                                strxml += '<ShiptoLocation LocationID="999999">' +
                                '<ERPReferenceID>'+ cpa.ORAAddressId__c +'</ERPReferenceID>' + 
                                '</ShiptoLocation>';
                            }else{
                                strxml += '<ShiptoLocation LocationID="999999">' +
                                '<Address1>'+ cdg.DeliverToStreet +'</Address1>' +
                                '<Address2></Address2>' +
                                '<Address3></Address3>' +
                                '<Address4></Address4>' +		
                                '<City>'+ cdg.DeliverToCity +'</City>' +
                                '<State>'+ cdg.DeliverToStateCode +'</State>' +
                                '<PostalCode>'+ cdg.DeliverToPostalCode +'</PostalCode>' +
                                '<CountryCode>'+ cdg.DeliverToCountryCode +'</CountryCode>' +
                                '<SiteNickname>'+ nickName +'</SiteNickname>' +
                            '</ShiptoLocation>';
                            }  
                        strxml += '</OrderHeader>' +
                        '<OrderLines>';
                        Integer i = 1;
                        for(CartItem ci : cartItemToUpdate){
                            strxml += '<OrderLine LineID="'+ i +'">' +      //'<OrderLine LineID="25012">' +
                                    //'<LineNumber>1</LineNumber>' +
                                    //'<ItemID>12334</ItemID>' +
                                    '<ItemNumber>' + ci.Product2.ProductCode + '</ItemNumber>' +  
                                    '<PricingQuantity>' + ci.Quantity + '</PricingQuantity>' +       
                                    // '<QuantityUOMCode>EA</QuantityUOMCode>' +
                                    '<UnitListPrice>' + ci.SalesPrice + '</UnitListPrice>' +     
                                '</OrderLine>';
                                i++;
                        }
                    strxml += '</OrderLines>' +
                    '</PricingRequest>';
                    System.debug('strxml=== '+JSON.serialize(strxml));
        return strxml;
    }

    public class PricingResult {
        public RequestResult RequestResult;
        public OrderHeader OrderHeader;
        public List<OrderLine> OrderLines;
    }

    public class RequestResult {
        public String Status;
        public String Message;
    }

    public class OrderHeader {
        public String HeaderID;
        public String CurrencyCode;
        public Decimal ERPReferenceID;
        public Decimal DiscountedShippingCharge;
    }

    public class OrderLine {
        public String LineID;
        public Decimal PricedQuantity;
        public Decimal PricedListPrice;
        public Decimal PricedSellingPrice;
        public List<Discount> Discounts;
    }

    public class Discount {
        public String DiscountID;
        public String DiscountName;
        public Decimal DiscountedAmount;
        public Decimal DiscountedPercent;
    }

    public class WrapperObject {
        public PricingResult PricingResult;
    }
    public class orderSummaryResponseWrapper{
        
        @AuraEnabled public Decimal OrderSubtotal = 0;
        @AuraEnabled public Decimal DiscountAdjustments = 0;
        @AuraEnabled public Decimal Tax = 0;
        @AuraEnabled public Decimal Shipping = 0;
        @AuraEnabled public Decimal ShippingDiscount = 0;
        @AuraEnabled public Decimal ShippingTax = 0;
        @AuraEnabled public Decimal TissueHandlingFee = 0;
        @AuraEnabled public Decimal Total = 0;
        @AuraEnabled public Decimal DummyTotal = 0;
        @AuraEnabled public String  currencyCode;
    }
}