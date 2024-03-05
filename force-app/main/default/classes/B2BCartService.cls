public with sharing class B2BCartService {
    
    private static final String CLASSNAME = 'B2BCartService';
    private static final String MODULE_NAME = 'Cart Module';
    private static B2B_Oracle_Settings__mdt oraclePricingApi = B2B_Oracle_Settings__mdt.getInstance('Oracle_Pricing_Api_endpoint');

    

    // public static Map<String,Object> validateCartTotal(Map<String,Object> mapParams){
    //     Boolean isSuccess = false;
    //     String message = '';
    //     if(mapParams.containsKey(B2BConstants.GRAND_TOTAL_AMOUNT) && mapParams.get(B2BConstants.GRAND_TOTAL_AMOUNT) != null){
    //         Boolean allowCheckout = B2BCartHelper.validateCartTotal(mapParams);
    //         mapParams.put(B2BConstants.ALLOW_CHECKOUT,allowCheckout);
    //         isSuccess = true;
    //     }else{
    //         message = 'Invalid Request.';
    //     }
    //     mapParams.put(B2BConstants.IS_SUCCESS,isSuccess);
    //     mapParams.put(B2BConstants.MESSAGE,message);
    //     return mapParams;
    // }

    public static Map<String,Object> getCpnFromCart(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        if(mapParams.containsKey(B2BConstants.CART_ID) && String.isNotBlank((String)mapParams.get(B2BConstants.CART_ID))){
            Map<String,Object> cartItemMap = B2BCartHelper.getCpnFromCart(mapParams);
            mapParams.put('cartItemMap',cartItemMap);
            isSuccess = true;
        }else{
            message = 'Invalid Request.';
        }
        mapParams.put(B2BConstants.IS_SUCCESS,isSuccess);
        mapParams.put(B2BConstants.MESSAGE,message);
        return mapParams;
    }

    public static Map<String,Object> calculateDiscountOnCart(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        Map<String,Object> resp = new Map<String,Object>();
        String cartItemId;
        List<String> cartItemIds = new List<String>();
        System.debug('calculateDiscountOnCart----- '+JSON.serialize(mapParams));
        if(!mapParams.isEmpty()){
            List<Object> origCartItemList = (List<Object>)mapParams.get('originalCartItems');
            System.debug('origCartItemList----- '+JSON.serialize(origCartItemList));
            //cartItemId = String.valueOf(mapParams.get('cartItemId'));
            for(Object ciObj : origCartItemList){
                Map<Object,Object> str = (Map<Object,Object>)ciObj;
                cartItemIds.add(String.valueOf(str.get('id')));
            }
            //cartItemIds.add(cartItemId);
            System.debug('cartItemIds list ----- '+JSON.serialize(cartItemIds));
            resp = makeAPICallout(cartItemIds); // todo: handle update after the response from api.
            if(resp.containsKey('errorResponse') || resp.containsKey('discountCalloutError')){
                isSuccess = false;
            }else {
                isSuccess = true;
            }
        }else{
            resp.put(B2BConstants.MESSAGE, 'input is empty');
        }
        mapParams.put(B2BConstants.IS_SUCCESS,isSuccess);
        return resp;
    }

    public static Map<String,Object> calculateDiscountOnItem(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        Map<String,Object> resp = new Map<String,Object>();
        String cartItemId;
        List<String> cartItemIds = new List<String>();
        System.debug('calculateDiscountOnItem----- '+mapParams);
        if(!mapParams.isEmpty()){
            cartItemId = String.valueOf(mapParams.get('cartItemId'));
            cartItemIds.add(cartItemId);
            resp = makeAPICallout(cartItemIds); // todo: handle update after the response from api.
            if(resp.containsKey('errorResponse') || resp.containsKey('discountCalloutError')){
                isSuccess = false;
            }else {
                isSuccess = true;
            }
        }else{
            resp.put(B2BConstants.MESSAGE, 'input is empty');
        }
        mapParams.put(B2BConstants.IS_SUCCESS,isSuccess);
        return resp;
    }

    public static Map<String,Object> makeAPICallout(List<String> cartItemId) {
        Map<String,Object> resp = new Map<String,Object>();
        List<OrderLine> respOrderLineList = new List<OrderLine>();
        String endpointUrl = oraclePricingApi.key__c;
        Map<String,Object> reqBodyMap = generateXMLBodyAllCart(cartItemId);
        //String xmlRequestBody = generateXMLBody(cartItemId);
        String xmlRequestBody = String.valueOf(reqBodyMap.get('strxml'));
        System.debug('xmlRequestBody=== '+JSON.serialize(xmlRequestBody));

        HttpRequest request = new HttpRequest();
        request.setTimeout(60000); //comment for test read time out error
        //request.setTimeout(10);
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/xml');
        request.setBody(xmlRequestBody);

        HttpResponse response = new Http().send(request);
        System.debug('response---- '+response);
        System.debug('responseBody---- '+response.getBody());
        if (response.getStatusCode() == 200) {
            // API call was successful
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
                respOrderLineList.add(orderLine);
                system.debug('wrapperObj==='+wrapperObj);
                resp.put('PricingResult', JSON.serialize(wrapperObj));
                
                if(wrapperObj?.PricingResult?.OrderLines != null){
                    resp.put('discountApplied', True);
                    updateAllCartItem(reqBodyMap, respOrderLineList);
                }else{
                    resp.put('discountApplied', false);
                }
                
            }
        } else {
            //retry api callout
            //System.enqueueJob(new B2B_PricingApiCallout(xmlRequestBody, endpointUrl, reqBodyMap, respOrderLineList));
            // API call failed
            String xmlErrorResponse = response.getBody();
            Map<String, Object> resultMap = XMLParser.xmlToMap(xmlErrorResponse);
            Map<String, Object> pricingResultMap = (Map<String, Object>) resultMap.get('PricingResult');
            String errorMessage = 'API callout failed with status code: ' + response.getStatusCode();
            resp.put('discountCalloutError', errorMessage);
            resp.put('errorResponse',pricingResultMap);
            // Handle the error
        }
        return resp;
    }

    //Wrappers start : added by Akash
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

    //Wrappers end: added by Akash
    public static void updateAllCartItem(Map<String,Object> reqBodyMap, List<OrderLine> respOrderLineList){
        List<CartItem> itemsToUpdate = new List<CartItem>();
        if(!respOrderLineList.isEmpty()){
            for(OrderLine oi : respOrderLineList){
                if(oi.Discounts != null){
                    List<Discount> discountResp = (List<Discount>)oi.Discounts;
                    Decimal discountAmount = (Decimal)discountResp[0].DiscountedAmount;
                    discountAmount = discountAmount * -1;
                    if(reqBodyMap.containsKey(String.valueOf(oi.LineID))){
                        CartItem ci = (CartItem)reqBodyMap.get(oi.LineID);
                        ci.AdjustmentAmount = discountAmount;
                        ci.TotalAdjustmentAmount = discountAmount;
                        ci.TotalPriceAfterAllAdjustments = ci.TotalLineAmount + discountAmount;
                        ci.TotalPrice = ci.TotalLineAmount + discountAmount;
                        //ci.TotalPromoAdjustmentAmount = discountAmount;   //removing this because this was doubling the discount value on cart.
                        itemsToUpdate.add(ci);
                    }else {
                        System.debug('error exception--- Map is empty'+oi);
                    }
                }
            }
            if(!itemsToUpdate.isEmpty()){
                System.debug('update itemsToUpdate'+itemsToUpdate);
                update itemsToUpdate;
            }else{
                System.debug('update itemsToUpdate failed ');
            }
        }
    }

    public static void updateCartItem(String cartItemId, Decimal discountAmount, Map<String, Object> discountMap){
        discountAmount = discountAmount.setScale(2);
        if(discountAmount < 0){
            CartItem cartItemToUpdate = [SELECT Id, AdjustmentAmount, AdjustmentTaxAmount, GrossAdjustmentAmount, NetAdjustmentAmount, 
                                        TotalAdjustmentAmount, TotalPriceAfterAllAdjustments, TotalLineAmount, UnitAdjustedPrice, UnitAdjustmentAmount, 
                                        cart.GrandTotalAmount, TotalPromoAdjustmentAmount, Quantity, SalesPrice, CartId, TotalPrice
                                        FROM CartItem where id =: cartItemId LIMIT 1];
            cartItemToUpdate.AdjustmentAmount = discountAmount;
            //cartItemToUpdate.AdjustmentTaxAmount          //to do UnitAdjustmentAmount, UnitAdjustedPrice
            cartItemToUpdate.TotalAdjustmentAmount = discountAmount;
            cartItemToUpdate.TotalPriceAfterAllAdjustments = cartItemToUpdate.TotalLineAmount + discountAmount;
            cartItemToUpdate.TotalPrice = cartItemToUpdate.TotalLineAmount + discountAmount;
            cartItemToUpdate.TotalPromoAdjustmentAmount = discountAmount;
            //cartItemToUpdate.UnitAdjustmentAmount = discountAmount/cartItemToUpdate.Quantity;
            update cartItemToUpdate;
        }
    }

    public static String generateXMLBody(List<String> cartItemId){ 
        String randomGUID = (String) ((Map<String,Object>) JSON.deserializeUntyped(new Auth.JWT().toJSONString())).get('jti');
        //String itemId = cartItemId;
        String accId;
        List<CartItem> cartItemToUpdate = [SELECT Id, Cart.AccountId, CartDeliveryGroup.DeliverToName, CurrencyIsoCode, Product2.Source_External_id__c, 
                                        Product2.ProductCode, Quantity, Product2.Unit_Measure__c, UnitAdjustedPrice, CartId, ListPrice, SalesPrice
                                        FROM CartItem where id = :cartItemId];
        accId = cartItemToUpdate[0].Cart.AccountId;
        Account acc = [SELECT Id, Oracle_Account_Number__c, Oracle_Address_ID__c FROM Account WHERE Id =: accId LIMIT 1];
        List<ContactPointAddress> cpaList = [SELECT Id, Name, Country, PostalCode, State, City, Street, ParentId, AddressType, ORAAddressId__c 
                                            FROM ContactPointAddress 
                                            WHERE ParentId =: accId AND AddressType = 'Shipping' AND ORAAddressId__c != Null];
                                            
        string strxml ='';
        strxml ='<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
                    '<PricingRequest TrackingGUID="' + randomGUID + '">' +  
                        '<OrderHeader HeaderID="' + cartItemToUpdate[0].CartId + '">' +                //'<OrderHeader HeaderID="184019">' +
                            '<OrderNumber>' + cartItemToUpdate[0].CartId + '</OrderNumber>' +          //'<OrderNumber>184019</OrderNumber>' +
                            '<CustomerID>' + acc.Oracle_Account_Number__c + '</CustomerID>' +                                     //'<CustomerID>417054</CustomerID>' + 
                            '<CustomerNumber>' + acc.Oracle_Account_Number__c + '</CustomerNumber>' +                             //'<CustomerNumber>418762</CustomerNumber>' +
                            // '<ShiptoName/>' +
                            // '<ShippingCarrier>FedEx</ShippingCarrier>' +
                            // '<CarrierService>FED1AM</CarrierService>' +
                            // '<ShippingCharge>31.00</ShippingCharge>' +
                            '<CurrencyCode>USD</CurrencyCode>' +
                            // '<ShiptoLocation LocationID="999999">' +
                            //     '<ERPReferenceID></ERPReferenceID>' +
                            //     '<Address1>26 wild rice dr</Address1>' +
                            //     '<Address2></Address2>' +
                            //     '<Address3></Address3>' +
                            //     '<Address4></Address4>' +		
                            //     '<City>Pawleys Island</City>' +
                            //     '<County>Georgetown</County>' +
                            //     '<State>SC</State>' +
                            //     '<PostalCode>29585</PostalCode>' +
                            //     '<CountryCode>US</CountryCode>' +
                            //     '<SiteNickname>SC Office</SiteNickname>' +
                            // '</ShiptoLocation>' +  
                        '</OrderHeader>' +
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

    public static Map<String,Object> generateXMLBodyAllCart(List<String> cartItemId){ 
        Map<String,Object> resp = new Map<String,Object>();
        String randomGUID = (String) ((Map<String,Object>) JSON.deserializeUntyped(new Auth.JWT().toJSONString())).get('jti');
        //String itemId = cartItemId;
        String accId;
        List<CartItem> cartItemToUpdate = [SELECT Id, Cart.AccountId, CartDeliveryGroup.DeliverToName, CurrencyIsoCode, Product2.Source_External_id__c, 
                                        Product2.ProductCode, Quantity, Product2.Unit_Measure__c, UnitAdjustedPrice, CartId, ListPrice,
                                        AdjustmentAmount, TotalAdjustmentAmount, TotalPriceAfterAllAdjustments, TotalPrice, TotalPromoAdjustmentAmount, TotalLineAmount, SalesPrice
                                        FROM CartItem where id = :cartItemId];
        accId = cartItemToUpdate[0].Cart.AccountId;
        Account acc = [SELECT Id, Oracle_Account_Number__c, Oracle_Address_ID__c FROM Account WHERE Id =: accId LIMIT 1];
        List<ContactPointAddress> cpaList = [SELECT Id, Name, Country, PostalCode, State, City, Street, ParentId, AddressType, ORAAddressId__c 
                                            FROM ContactPointAddress 
                                            WHERE ParentId =: accId AND AddressType = 'Shipping' AND ORAAddressId__c != Null];
                                            
        string strxml ='';
        strxml ='<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
                    '<PricingRequest TrackingGUID="' + randomGUID + '">' +  
                        '<OrderHeader HeaderID="' + cartItemToUpdate[0].CartId + '">' +                //'<OrderHeader HeaderID="184019">' +
                            '<OrderNumber>' + cartItemToUpdate[0].CartId + '</OrderNumber>' +          //'<OrderNumber>184019</OrderNumber>' +
                            '<CustomerID>' + acc.Oracle_Account_Number__c + '</CustomerID>' +                                     //'<CustomerID>417054</CustomerID>' + 
                            '<CustomerNumber>' + acc.Oracle_Account_Number__c + '</CustomerNumber>' +                             //'<CustomerNumber>418762</CustomerNumber>' +
                            '<CurrencyCode>USD</CurrencyCode>' +
                        '</OrderHeader>' +
                        '<OrderLines>';
                        Integer i = 1;
                        for(CartItem ci : cartItemToUpdate){
                            resp.put(String.valueOf(i), ci);
                            strxml += '<OrderLine LineID="'+ i +'">' +      //'<OrderLine LineID="25012">' +
                                    '<ItemNumber>' + ci.Product2.ProductCode + '</ItemNumber>' +  
                                    '<PricingQuantity>' + ci.Quantity + '</PricingQuantity>' +       
                                    '<UnitListPrice>' + ci.SalesPrice + '</UnitListPrice>' +     
                                '</OrderLine>';
                                i++;
                        }
                    strxml += '</OrderLines>' +
                    '</PricingRequest>';
                    System.debug('strxml=== '+JSON.serialize(strxml));
                    resp.put('strxml', String.valueOf(strxml));

                    System.debug('resp=== '+JSON.serialize(resp));
        return resp;
    }

    public static Map<String,Object> deleteCartShippingAndTax(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        Map<String,Object> resp = new Map<String,Object>();
        String cartItemId;
        String cartId;
        List<String> cartItemIds = new List<String>();
        System.debug('deleteCartShippingAndTax----- '+JSON.serialize(mapParams));
        if(!mapParams.isEmpty()){
            List<Object> origCartItemList = (List<Object>)mapParams.get('originalCartItems');
            System.debug('origCartItemList----- '+JSON.serialize(origCartItemList));
            if(!origCartItemList.isEmpty()){
                Map<Object,Object> str = (Map<Object,Object>)origCartItemList[0];
                cartItemId = String.valueOf(str.get('id'));
                cartId = [SELECT Id, CartId FROM CartItem WHERE Id = :cartItemId LIMIT 1].CartId;
            }
                isSuccess = true;
                resp.put('cartId', cartId);
                deleteTaxtData(cartId);
                deleteShippingData(cartId);
        }else{
            resp.put(B2BConstants.MESSAGE, 'input is empty');
        }
        mapParams.put(B2BConstants.IS_SUCCESS,isSuccess);
        return resp;
    }

    public static void deleteShippingData(Id cartId){
        Id cartDeliveryGroupId = [SELECT CartDeliveryGroupId FROM CartItem WHERE CartId = :cartId][0].CartDeliveryGroupId;
        //database.delete([SELECT Id FROM CartDeliveryGroupMethod WHERE CartDeliveryGroupId = :cartDeliveryGroupId],false);
        database.delete([SELECT Id, Type FROM CartItem WHERE CartId = :cartId AND Type = 'Charge'],false);
    }

    public static void deleteTaxtData(Id cartId){
        Map<String, Id> cartItemIdsBySKU = new Map<String, Id>();
        for (CartItem cartItem : [SELECT Sku, TotalPrice, Type FROM CartItem WHERE CartId = :cartId]) {
            String cartItemSKU = '';
            if (cartItem.Type == 'Product') {
                cartItemSKU = cartItem.Sku;
            }
            else if (cartItem.Type == 'Charge') {
                cartItemSKU = 'ChargeSKU';
            }
            cartItemIdsBySKU.put(cartItemSKU, cartItem.Id);
        }
        
        List<Id> cartItemIds = cartItemIdsBySKU.values();
        delete [SELECT Id FROM CartTax WHERE CartItemId IN :cartItemIds];
    }

}