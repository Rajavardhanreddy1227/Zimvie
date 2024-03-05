public with sharing class B2B_AddressValidationController {
    
    private static B2B_Google_API__mdt googleApi = B2B_Google_API__mdt.getInstance('Address_Validation_API');
    private static B2B_Oracle_Settings__mdt oraclePricingApi = B2B_Oracle_Settings__mdt.getInstance('Oracle_Pricing_Api_endpoint');
    @AuraEnabled
    public static Map<String,Object> validateAddress(String city,String countryCode,String stateCode,String postalCode,String street,String accountId){
        try {

            B2B_AddressValidationWrapper request = new B2B_AddressValidationWrapper();
            B2B_AddressValidationWrapper.RequestAddress reqAddress = new B2B_AddressValidationWrapper.RequestAddress();
            Map<String,Object> response = new Map<String,Object>();
            
            Account acc = [Select id,name,BillingCountry,BillingCountryCode From Account where id=:accountId];
            if(acc != null){
                response.put('billingCountry',acc.BillingCountry);
                response.put('billingCountryCode',acc.BillingCountryCode);
            }
            reqAddress.regionCode = countryCode;
            reqAddress.locality = city;
            reqAddress.administrativeArea = stateCode;
            reqAddress.postalCode = postalCode;
            reqAddress.addressLines = new List<String>{street};
            
            request.address = reqAddress;
            request.enableUspsCass = false;
            
            System.debug('request>>>'+JSON.serializePretty(request));
            String key = googleApi.API_Key__c;
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Address_Validation_Api?key='+key);
            req.setMethod('POST');
            req.setBody(JSON.serialize(request));
            req.setHeader('Content-Type', 'application/json');
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('res>>'+res.getBody());
            response.put('status',res.getStatus());
            response.put('statusCode',res.getStatusCode());
            response.put('validationResponse',JSON.deserializeUntyped(res.getBody()));
            System.debug('response>>'+response);
            return response;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String,Object> getOracleIdAndStore(String city,String countryCode,String stateCode,String postalCode,String street,String accountId, String nickName, String commId, String addressId){
        Map<String,Object> response = new Map<String,Object>();
        try {
            ConnectApi.CartSummary cartSummObj = RSM_CartController.getCartSummaryLWR(commId, Null, Null);
            if(cartSummObj != null){
                String cartId = cartSummObj.cartId;
                response = makeApiCallout(cartId, accountId, city, countryCode, stateCode, postalCode, street, nickName, addressId);
                response.put('currentCartId', cartId);
            }else{
                response = makeApiCallout(null, accountId, city, countryCode, stateCode, postalCode, street, nickName, addressId);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Map<String,Object> updateContactAddress(String addressId, String oraId){
        Map<String,Object> response = new Map<String,Object>();
        try {
            ContactPointAddress cpaList = [SELECT Id, ORAAddressId__c FROM ContactPointAddress WHERE Id =: addressId LIMIT 1];
            cpaList.ORAAddressId__c = Decimal.valueOf(oraId);
            update cpaList;
            response.put('updatedContactPointAddress', cpaList);
        } catch (Exception e) {
            response.put('Error', 'Error in updateContactAddress');
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Map<String,Object> deleteContactPointAddress(String addressId){
        Map<String,Object> response = new Map<String,Object>();
        try {
            ContactPointAddress cpaList = [SELECT Id, ORAAddressId__c FROM ContactPointAddress WHERE Id =: addressId LIMIT 1];
            //cpaList.ORAAddressId__c = Decimal.valueOf(oraId);
            delete cpaList;
            response.put('deleteContactPointAddress', 'deleted');
        } catch (Exception e) {
            response.put('Error', 'Error in deleteContactPointAddress');
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Map<String,Object> validateNickName(Map<String,Object> inpMap){
        Map<String,Object> response = new Map<String,Object>();
        Map<String,Object> existingCpaMap = new Map<String,Object>();
        try {
            String accId = (String)inpMap.get('accId');
            String nickName = (String)inpMap.get('nickName');
            String key = accId + '-' + nickName;
            key = key.toLowerCase();
            System.debug('key---'+ key);
            List<ContactPointAddress> cpaList = [SELECT Id, ORAAddressId__c, AddressType, ParentId, Name FROM ContactPointAddress WHERE ParentId = :accId];
            for(ContactPointAddress cpa : cpaList){
                string cpaAccId = cpa.ParentId;
                if(cpaAccId.length() == 18){
                    cpaAccId = cpaAccId.substring(0,cpaAccId.length()-3);
                    string mapkey = cpaAccId + '-' + cpa.name;
                    mapkey = mapkey.toLowerCase();
                    existingCpaMap.put(mapkey, cpa);
                }else{
                    System.debug('account id problem, Exception, error---');
                }
            }
            System.debug('existingCpaMap---'+ existingCpaMap);
            if(existingCpaMap.containsKey(key)){
                response.put('alreadyExists', true);
                response.put('existingRecord', existingCpaMap.get(key));
            }else{
                response.put('alreadyExists', false);
            }
        } catch (Exception e) {
            response.put('Error', 'Error in deleteContactPointAddress');
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    public static Map<String,Object> makeApiCallout(String cartId, String accountId, String city, String countryCode, String stateCode, String postalCode, String street, String nickName, String addressId){
        Map<String,Object> resp = new Map<String,Object>();
        // String endpointUrl = 'https://dev-ecomm.zimvie.com/ords/psp_datahub/datahub/ecmprice';
        String endpointUrl = oraclePricingApi.key__c;
        String xmlRequestBody = generateXMLBody(cartId, accountId, city, countryCode, stateCode, postalCode, street, nickName);
        HttpRequest request = new HttpRequest();
        request.setTimeout(60000);
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
            }
            
            system.debug('wrapperObj==='+JSON.serialize(wrapperObj));
            resp.put('PricingResult', JSON.serialize(wrapperObj));
            if(wrapperObj?.PricingResult?.OrderHeader?.ERPReferenceID != null){
                Decimal oracleAddressId = wrapperObj?.PricingResult?.OrderHeader?.ERPReferenceID;
                resp.put('oracleAddressId', String.valueOf(oracleAddressId));
                resp = updateContactAddress(addressId, String.valueOf(oracleAddressId));
            }else{
                resp.put('Error to get oracleAddressId', null);
            }
        }
        else{
            //retryable api callout
            //System.enqueueJob(new B2B_OracleAddressCallout_Retry(xmlRequestBody, endpointUrl, addressId));
            String xmlErrorResponse = response.getBody();
            Map<String, Object> resultMap = XMLParser.xmlToMap(xmlErrorResponse);
            Map<String, Object> pricingResultMap = (Map<String, Object>) resultMap.get('PricingResult');
            String errorMessage = 'API callout failed with status code: ' + response.getStatusCode();
            resp.put('discountCalloutError', errorMessage);
            resp.put('errorResponse',pricingResultMap);
        }
        return resp;
    }

    public static String generateXMLBody(String cartId, String accountId, String city, String countryCode, String stateCode, String postalCode, String street, String nickName){ 
        nickName = nickName.replace('&', 'and');
        String randomGUID = (String) ((Map<String,Object>) JSON.deserializeUntyped(new Auth.JWT().toJSONString())).get('jti');
        //String itemId = cartItemId;
        String accId;
        List<CartItem> cartItemToUpdate = new List<CartItem>();
        if(cartId != null){
            cartItemToUpdate = [SELECT Id, Cart.AccountId, CartDeliveryGroup.DeliverToName, CurrencyIsoCode, Product2.Source_External_id__c, 
                                        Product2.ProductCode, Quantity, Product2.Unit_Measure__c, UnitAdjustedPrice, CartId, ListPrice, Type, SalesPrice
                                        FROM CartItem where CartId = :cartId AND Type = 'Product'];
        }else{
            cartId = accountId;
        }
        accId = accountId;
        Account acc = [SELECT Id, Oracle_Account_Number__c, Oracle_Address_ID__c FROM Account WHERE Id =: accId LIMIT 1];
        // List<ContactPointAddress> cpaList = [SELECT Id, Name, Country, PostalCode, State, City, Street, ParentId, AddressType, ORAAddressId__c 
        //                                     FROM ContactPointAddress 
        //                                     WHERE ParentId =: accId AND AddressType = 'Shipping' AND ORAAddressId__c != Null];
        if(stateCode == NULL || String.isEmpty(stateCode)){
            stateCode = city;
        }
        string strxml ='';
        strxml ='<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
                    '<PricingRequest TrackingGUID="' + randomGUID + '">' +  
                        '<OrderHeader HeaderID="' + cartId + '">' +                //'<OrderHeader HeaderID="184019">' +
                            '<OrderNumber>' + cartId + '</OrderNumber>' +          //'<OrderNumber>184019</OrderNumber>' +
                            '<CustomerID>' + acc.Oracle_Account_Number__c + '</CustomerID>' +                                     //'<CustomerID>417054</CustomerID>' + 
                            '<CustomerNumber>' + acc.Oracle_Account_Number__c + '</CustomerNumber>' +                             //'<CustomerNumber>418762</CustomerNumber>' +
                            '<ShiptoName/>' +
                            '<CurrencyCode>USD</CurrencyCode>' +
                            '<ShiptoLocation LocationID="999999">' +
                                '<ERPReferenceID></ERPReferenceID>' +
                                '<Address1>'+ street +'</Address1>' +
                                '<Address2></Address2>' +
                                '<Address3></Address3>' +
                                '<Address4></Address4>' +		
                                '<City>'+ city +'</City>' +
                                // '<County>Georgetown</County>' + 
                                '<State>'+ stateCode +'</State>' +
                                '<PostalCode>'+ postalCode +'</PostalCode>' +
                                '<CountryCode>'+ countryCode +'</CountryCode>' +
                                '<SiteNickname>'+ nickName +'</SiteNickname>' +
                            '</ShiptoLocation>' +  
                        '</OrderHeader>';
                        if(!cartItemToUpdate.isEmpty()){
                            strxml += '<OrderLines>';
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
                            strxml += '</OrderLines>';
                        }
                        strxml += '</PricingRequest>';
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
}