// This must implement the sfdc_checkout.CartTaxCalculations interface
// in order to be processed by the checkout flow and used for your Taxes integration.
global class B2BTaxZimVie implements sfdc_checkout.CartTaxCalculations {
    public Static Map<String,Object> entryVsCartItemMap = new Map<String,Object>();

    private static B2B_Oracle_Settings__mdt oracleTaxApi = B2B_Oracle_Settings__mdt.getInstance('Oracle_Tax_Api_endpoint');

    global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        try {
            // In the Spring '20 release, there should be one delivery group per cart.
            // In the future, when multiple delivery groups can be created,
            // this sample should be updated to loop through all delivery groups.

            // We need to get the ID of the delivery group in order to get the DeliverTo info.
            Id cartDeliveryGroupId = [SELECT CartDeliveryGroupId FROM CartItem WHERE CartId = :cartId][0].CartDeliveryGroupId;
            CartDeliveryGroup deliveryGroup = [SELECT DeliverToState, DeliverToCountry FROM CartDeliveryGroup WHERE Id = :cartDeliveryGroupId][0];
            
            // Get all SKUs, the cart item IDs, and the total prices from the cart items.
            Map<String, Id> cartItemIdsBySKU = new Map<String, Id>();
            Map<String, Decimal> cartItemTotalPriceBySKU = new Map<String, Decimal>();
            for (CartItem cartItem : [SELECT Sku, TotalPrice, Type FROM CartItem WHERE CartId = :cartId]) {
                String cartItemSKU = '';
                if (cartItem.Type == 'Product') {
                    if (String.isBlank(cartItem.Sku)) {
                        String errorMessage = 'The SKUs for all products in your cart must be defined.';
                        return integrationStatusFailedWithCartValidationOutputError(
                            integStatus,
                            errorMessage,
                            jobInfo,
                            cartId
                        );
                    }
                    cartItemSKU = cartItem.Sku;
                }
                else if (cartItem.Type == 'Charge') {
                    // This is an example for a Cart Item of type shipping charge.
                    // For simplicity and testing purposes, we just assign some SKU to this charge so that the taxation external service returns some value.
                    cartItemSKU = 'ChargeSKU';
                }
                cartItemIdsBySKU.put(cartItemSKU, cartItem.Id);
                cartItemTotalPriceBySKU.put(cartItemSKU, cartItem.TotalPrice);
            }      
            
            // Get the tax rates and tax amounts from an external service
            // Other parameters will be passed here, like ship_from, bill_to, more details about the ship_to, etc.
            Map<String, TaxDataFromExternalService> rateAndAmountFromExternalServicePerSku = getTaxRatesAndAmountsFromExternalService(
                cartItemTotalPriceBySKU, deliveryGroup.DeliverToState, deliveryGroup.DeliverToCountry
            );
            
            // If there are taxes from a previously cancelled checkout, delete them.
            List<Id> cartItemIds = cartItemIdsBySKU.values();
            delete [SELECT Id FROM CartTax WHERE CartItemId IN :cartItemIds];
            
            // For each cart item, insert a new tax line in the CartTax entity.
            // The total tax is automatically rolled up to TotalLineTaxAmount in the corresponding CartItem line.
            CartTax[] cartTaxestoInsert = new CartTax[]{};
            for (String sku : cartItemIdsBySKU.keySet()) {
                TaxDataFromExternalService rateAndAmountFromExternalService = rateAndAmountFromExternalServicePerSku.get(sku);
                if (rateAndAmountFromExternalService == null){
                    return integrationStatusFailedWithCartValidationOutputError(
                        integStatus,
                        'The product with sku ' + sku + ' could not be found in the external system',
                        jobInfo,
                        cartId
                    );
                }
                // If the sku was found in the external system, add a new CartTax line for that sku
                // The following fields from CartTax can be filled in:
                // Amount (required): Calculated tax amount.
                // CartItemId (required): ID of the cart item.
                // Description (optional): Description of CartTax.
                // Name (required): Name of the tax.
                // TaxCalculationDate (required): Calculation date for this tax line.
                // TaxRate (optional): The percentage value of the tax. Null if the tax is a flat amount.
                // TaxType (required): The type of tax, e.g. Actual or Estimated.
                CartTax tax = new CartTax( 
                    Amount = rateAndAmountFromExternalService.getAmount().setScale(2),
                    CartItemId = cartItemIdsBySKU.get(sku),
                    Name = rateAndAmountFromExternalService.getTaxName(),
                    TaxCalculationDate = Date.today(),
                    TaxRate = rateAndAmountFromExternalService.getRate(),
                    TaxType = 'Actual'
                );
                cartTaxestoInsert.add(tax);
            }
            insert(cartTaxestoInsert);
            integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
        } catch(Exception e) {
            // For testing purposes, this example treats exceptions as user errors, which means they are displayed to the buyer user.
            // In production you probably want this to be an admin-type error. In that case, throw the exception here
            // and make sure that a notification system is in place to let the admin know that the error occurred.
            // See the readme section about error handling for details about how to create that notification.
            return integrationStatusFailedWithCartValidationOutputError(
                integStatus,
                'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage(),
                jobInfo,
                cartId
            );
        }
        return integStatus;
    }
    public Map<String,TaxDataFromExternalService> getTaxFromOracle(String inputCartId){
        Map<String, TaxDataFromExternalService> taxDataFromExternalServiceBySKU = new Map<String, TaxDataFromExternalService>();
        Map<String,Object> indexVsResponseValues = new Map<String,Object>();
        //try {
            //String endpointUrl = 'https://dev-ecomm.zimvie.com/ords/psp_datahub/datahub/ecmtax';
            String endpointUrl = oracleTaxApi.key__c;
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

                // Parse TaxResult
                Dom.XmlNode TaxResultNode = doc.getRootElement();
                wrapperObj.TaxResult = new TaxResult();

                // Parse RequestResult
                Dom.XmlNode requestResultNode = TaxResultNode.getChildElement('RequestResult', null);
                wrapperObj.TaxResult.RequestResult = new RequestResult();
                wrapperObj.TaxResult.RequestResult.Status = requestResultNode.getChildElement('Status', null).getText();
                wrapperObj.TaxResult.RequestResult.Message = requestResultNode.getChildElement('Message', null).getText();

                // Parse OrderHeader
                Dom.XmlNode orderHeaderNode = TaxResultNode.getChildElement('OrderHeader', null);
                wrapperObj.TaxResult.OrderHeader = new OrderHeader();
                wrapperObj.TaxResult.OrderHeader.HeaderID = orderHeaderNode.getAttribute('HeaderID',null);
                wrapperObj.TaxResult.OrderHeader.CurrencyCode = orderHeaderNode.getChildElement('CurrencyCode', null).getText();
                wrapperObj.TaxResult.OrderHeader.ShippingCarrier = orderHeaderNode.getChildElement('ShippingCarrier', null).getText();
                wrapperObj.TaxResult.OrderHeader.CarrierService = orderHeaderNode.getChildElement('CarrierService', null).getText();
                wrapperObj.TaxResult.OrderHeader.ShippingTaxAmount = Decimal.valueOf(orderHeaderNode.getChildElement('ShippingTaxAmount', null).getText());
                

                // Parse OrderLines
                List<Dom.XmlNode> orderLineNodes = TaxResultNode.getChildElement('OrderLines', null).getChildElements();
                wrapperObj.TaxResult.OrderLines = new List<OrderLine>();
                for (Dom.XmlNode orderLineNode : orderLineNodes) {
                    OrderLine orderLine = new OrderLine();
                    orderLine.LineID = orderLineNode.getAttribute('LineID',null);
                    orderLine.UnitTaxAmount = Decimal.valueOf(orderLineNode.getChildElement('UnitTaxAmount', null).getText());
                    orderLine.AppliedRate = Decimal.valueOf(orderLineNode.getChildElement('AppliedRate', null).getText());
                    orderLine.TaxCode = orderLineNode.getChildElement('TaxCode', null).getText();
                    wrapperObj.TaxResult.OrderLines.add(orderLine);
                    indexVsResponseValues.put(orderLine.LineID, orderLine);
                }
                system.debug('wrapperObj==='+JSON.serialize(wrapperObj));
                system.debug('indexVsResponseValues==='+JSON.serialize(indexVsResponseValues));
                system.debug('entryVsCartItemMap==='+JSON.serialize(entryVsCartItemMap));
                for(String index : entryVsCartItemMap.keySet()){
                    CartItem cItem = (CartItem)entryVsCartItemMap.get(index);
                    system.debug('cItem==='+JSON.serialize(cItem));
                    B2BTaxZimVie.OrderLine apiObj = (B2BTaxZimVie.OrderLine)indexVsResponseValues.get(index);
                    system.debug('obj==='+JSON.serialize(apiObj));
                    taxDataFromExternalServiceBySKU.put(cItem.Product2.ProductCode,  new TaxDataFromExternalService(
                        (Decimal)apiObj.AppliedRate,
                        (Decimal)apiObj.UnitTaxAmount,
                        (String)apiObj.TaxCode
                    ));
                    //taxDataFromExternalServiceBySKU.put(arg0, arg1);
                }
                taxDataFromExternalServiceBySKU.put('ChargeSKU', new TaxDataFromExternalService(
                    (Decimal)0,
                    (Decimal)wrapperObj.TaxResult.OrderHeader.ShippingTaxAmount,
                    (String)'ShppingTax'
                ));
            }
            else{
                //retry api call
                ////System.enqueueJob(new B2B_OracleTaxApi_Retry(xmlRequestBody, endpointUrl, entryVsCartItemMap, inputCartId));

                // String xmlErrorResponse = response.getBody();
                // Map<String, Object> resultMap = XMLParser.xmlToMap(xmlErrorResponse);
                // Map<String, Object> pricingResultMap = (Map<String, Object>) resultMap.get('PricingResult');
                // String errorMessage = 'API callout failed with status code: ' + response.getStatusCode();
                // resp.put('discountCalloutError', errorMessage);
                // resp.put('errorResponse',pricingResultMap);
            }
        // }catch (Exception e) {
        //     System.debug('B2BTaxZimVie exception---- '+e);
        // }
        system.debug('taxDataFromExternalServiceBySKU==='+JSON.serialize(taxDataFromExternalServiceBySKU));
        return taxDataFromExternalServiceBySKU;
    }

    public static String generateXMLBody(String cartId){ 
        String randomGUID = (String) ((Map<String,Object>) JSON.deserializeUntyped(new Auth.JWT().toJSONString())).get('jti');
        //String itemId = cartItemId;
        String accId;
        WebCart cartObj = [SELECT Id, Selected_Contact_Point_Address__c FROM WebCart WHERE Id = :cartId LIMIT 1];
        ContactPointAddress cpaObj = [SELECT Id, ORAAddressId__c FROM ContactPointAddress WHERE Id = :cartObj.Selected_Contact_Point_Address__c LIMIT 1];
        if(cpaObj.ORAAddressId__c != Null){

        }
        else{

        }
        List<CartItem> cartItemToUpdate = [SELECT Id, Cart.AccountId, CartDeliveryGroup.DeliverToName, CurrencyIsoCode, Product2.Source_External_id__c, 
                                        Product2.ProductCode, Quantity, Product2.Unit_Measure__c, UnitAdjustedPrice, CartId, ListPrice, Type, TotalPrice
                                        FROM CartItem where CartId = :cartId AND Type = 'Product'];
        CartItem chargeItem = [SELECT Id, UnitAdjustedPrice, CartId, ListPrice, Type, TotalPrice
                                FROM CartItem where CartId = :cartId AND Type = 'Charge' LIMIT 1];
        System.debug('cartItemToUpdate:: ' +cartItemToUpdate);
        
        accId = cartItemToUpdate[0].Cart.accountId;
        System.debug('accId:: ' +accId);
        Account acc = [SELECT Id, Oracle_Account_Number__c, Oracle_Address_ID__c, CurrencyIsoCode FROM Account WHERE Id =: accId LIMIT 1];
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
                    '<TaxRequest TrackingGUID="' + randomGUID + '">' +  
                        '<OrderHeader HeaderID="' + cartId + '">' +
                            '<OrderNumber>' + cartId + '</OrderNumber>' +
                            '<CustomerID>' + acc.Oracle_Account_Number__c + '</CustomerID>' +
                            '<CustomerNumber>' + acc.Oracle_Account_Number__c + '</CustomerNumber>' + 
                            '<ShiptoLocationID>' + cpaObj.ORAAddressId__c + '</ShiptoLocationID>' +
                            //'<ShiptoName/>' +
                            '<ShippingCarrier>'+ cdg.DeliveryMethod.Carrier +'</ShippingCarrier>' +
                            '<CarrierService>'+ cdg.DeliveryMethod.ClassOfService +'</CarrierService>' +
                            '<ShippingCharge>'+ chargeItem.TotalPrice +'</ShippingCharge>' +
                            '<CurrencyCode>' + acc.CurrencyIsoCode + '</CurrencyCode>' +
                        '</OrderHeader>' +
                        '<OrderLines>';
                        Integer i = 1;
                        for(CartItem ci : cartItemToUpdate){
                            entryVsCartItemMap.put(String.valueOf(i), ci);
                            Decimal unitSellingPrice = ci.TotalPrice / ci.Quantity;
                            unitSellingPrice = unitSellingPrice.setScale(2);
                            strxml += '<OrderLine LineID="'+ i +'">' +      //'<OrderLine LineID="25012">' +
                                    //'<LineNumber>1</LineNumber>' +
                                    //'<ItemID>12334</ItemID>' +
                                    '<ItemNumber>' + ci.Product2.ProductCode + '</ItemNumber>' +  
                                    '<OrderedQuantity>' + ci.Quantity + '</OrderedQuantity>' +       
                                    // '<QuantityUOMCode>EA</QuantityUOMCode>' +
                                    '<UnitSellingPrice>' + unitSellingPrice + '</UnitSellingPrice>' +     
                                '</OrderLine>';
                                i++;
                        }
                    strxml += '</OrderLines>' +
                    '</TaxRequest>';
                    System.debug('strxml=== '+strxml);
        return strxml;
    }
    
    private Map<String, TaxDataFromExternalService> getTaxRatesAndAmountsFromExternalService (
        Map<String, Decimal> cartItemTotalAmountBySKU, String state, String country) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            Integer SuccessfulHttpRequest = 200;
            String encodedState = (state == null) ? '' : EncodingUtil.urlEncode(state, 'UTF-8').replace('+', '%20');
            String encodedCountry = (country == null) ? '' : EncodingUtil.urlEncode(country, 'UTF-8').replace('+', '%20');
            
            Map<String, Decimal> encodedCartItemTotalAmountBySKU = new Map<String, Decimal>();
            for(String sku: cartItemTotalAmountBySKU.keySet()) {
                encodedCartItemTotalAmountBySKU.put(EncodingUtil.urlEncode(sku, 'UTF-8'), cartItemTotalAmountBySKU.get(sku));
            }
            
            // To access the service below, you may need to add endpoint = https://b2b-commerce-test.herokuapp.com in Setup | Security | Remote site settings.
            String requestURL = 'https://b2b-commerce-test.herokuapp.com/get-tax-rates?state=' + encodedState
                            + '&country=' + encodedCountry
                            + '&amountsBySKU=' + JSON.serialize(encodedCartItemTotalAmountBySKU);
            request.setEndpoint(requestURL);
            request.setMethod('GET');
            HttpResponse response = http.send(request);
        
            // If the request is successful, parse the JSON response;
            // The response includes the tax amount, rate, and name for each SKU. It looks something like this:
            // {"SKU_1_september10-1568355297":{"taxAmount":2.8229012971048855,"taxRate":0.08,"taxName":"GST"},"SKU_0_september10-1568355296":{"taxAmount":5.0479003481482385,"taxRate":0.08,"taxName":"GST"}}
            if (response.getStatusCode() == SuccessfulHttpRequest) {
                Map<String, Object> resultsFromExternalServiceBySKU = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, TaxDataFromExternalService> taxDataFromExternalServiceBySKU = new Map<String, TaxDataFromExternalService>();
                for (String sku : resultsFromExternalServiceBySKU.keySet()) {
                    Map<String, Object> rateAndAmountFromExternalService = (Map<String, Object>) resultsFromExternalServiceBySKU.get(sku);
                    taxDataFromExternalServiceBySKU.put(sku, new TaxDataFromExternalService(
                        (Decimal)rateAndAmountFromExternalService.get('taxRate'),
                        (Decimal)rateAndAmountFromExternalService.get('taxAmount'),
                        (String)rateAndAmountFromExternalService.get('taxName')
                    ));
                }
                return taxDataFromExternalServiceBySKU;
            }
            else {
                throw new CalloutException ('There was a problem with the request. Error: ' + response.getStatusCode());
            }
    }
    
    // Structure to store the tax data retrieved from external service
    // This simplifies our ability to access it when storing it in Salesforce's CartTax entity
    Class TaxDataFromExternalService {
        private Decimal rate;
        private Decimal amount;
        private String taxName;
        
        public TaxDataFromExternalService () {
            rate = 0.0;
            amount = 0.0;
            taxName = '';
        }
        
        public TaxDataFromExternalService (Decimal someRate, Decimal someAmount, String someTaxName) {
            rate = someRate;
            amount = someAmount;
            taxName = someTaxName;
        }
        
        public Decimal getRate() {
            return rate;
        }
        
        public Decimal getAmount() {
            return amount;
        }
        
        public String getTaxName() {
            return taxName;
        }
    }
    
    private sfdc_checkout.IntegrationStatus integrationStatusFailedWithCartValidationOutputError(
        sfdc_checkout.IntegrationStatus integrationStatus, String errorMessage, sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
            integrationStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
            // For the error to be propagated to the user, we need to add a new CartValidationOutput record.
            // The following fields must be populated:
            // BackgroundOperationId: Foreign Key to the BackgroundOperation
            // CartId: Foreign key to the WebCart that this validation line is for
            // Level (required): One of the following - Info, Error, or Warning
            // Message (optional): Message displayed to the user (maximum 255 characters)
            // Name (required): The name of this CartValidationOutput record. For example CartId:BackgroundOperationId
            // RelatedEntityId (required): Foreign key to WebCart, CartItem, CartDeliveryGroup
            // Type (required): One of the following - SystemError, Inventory, Taxes, Pricing, Shipping, Entitlement, Other
            CartValidationOutput cartValidationError = new CartValidationOutput(
                BackgroundOperationId = jobInfo.jobId,
                CartId = cartId,
                Level = 'Error',
                Message = errorMessage.left(255),
                Name = (String)cartId + ':' + jobInfo.jobId,
                RelatedEntityId = cartId,
                Type = 'Taxes'
            );
            insert(cartValidationError);
            return integrationStatus;
    }

    global Map<String,Object> startCustomTaxIntegration(Id cartId){
        Map<String,Object> resp = new Map<String,Object>();
        try {

            //Map<String, TaxDataFromExternalService> respMap = getTaxFromOracle(cartId);
            // In the Spring '20 release, there should be one delivery group per cart.
            // In the future, when multiple delivery groups can be created,
            // this sample should be updated to loop through all delivery groups.

            // We need to get the ID of the delivery group in order to get the DeliverTo info.
            Id cartDeliveryGroupId = [SELECT CartDeliveryGroupId FROM CartItem WHERE CartId = :cartId][0].CartDeliveryGroupId;
            CartDeliveryGroup deliveryGroup = [SELECT DeliverToState, DeliverToCountry FROM CartDeliveryGroup WHERE Id = :cartDeliveryGroupId][0];
            
            // Get all SKUs, the cart item IDs, and the total prices from the cart items.
            Map<String, Id> cartItemIdsBySKU = new Map<String, Id>();
            Map<String, Decimal> cartItemTotalPriceBySKU = new Map<String, Decimal>();
            for (CartItem cartItem : [SELECT Sku, TotalPrice, Type FROM CartItem WHERE CartId = :cartId]) {
                String cartItemSKU = '';
                if (cartItem.Type == 'Product') {
                    if (String.isBlank(cartItem.Sku)) {
                        // String errorMessage = 'The SKUs for all products in your cart must be defined.';
                        // return integrationStatusFailedWithCartValidationOutputError(
                        //     integStatus,
                        //     errorMessage,
                        //     jobInfo,
                        //     cartId
                        // );
                    }
                    cartItemSKU = cartItem.Sku;
                }
                else if (cartItem.Type == 'Charge') {
                    // This is an example for a Cart Item of type shipping charge.
                    // For simplicity and testing purposes, we just assign some SKU to this charge so that the taxation external service returns some value.
                    cartItemSKU = 'ChargeSKU';
                }
                cartItemIdsBySKU.put(cartItemSKU, cartItem.Id);
                cartItemTotalPriceBySKU.put(cartItemSKU, cartItem.TotalPrice);
            }      
            
            // Get the tax rates and tax amounts from an external service
            // Other parameters will be passed here, like ship_from, bill_to, more details about the ship_to, etc.
            Map<String, TaxDataFromExternalService> rateAndAmountFromExternalServicePerSku = getTaxFromOracle(cartId); 
            /*getTaxRatesAndAmountsFromExternalService(
                cartItemTotalPriceBySKU, deliveryGroup.DeliverToState, deliveryGroup.DeliverToCountry
            );*/
            
            // If there are taxes from a previously cancelled checkout, delete them.
            List<Id> cartItemIds = cartItemIdsBySKU.values();
            delete [SELECT Id FROM CartTax WHERE CartItemId IN :cartItemIds];
            
            // For each cart item, insert a new tax line in the CartTax entity.
            // The total tax is automatically rolled up to TotalLineTaxAmount in the corresponding CartItem line.
            CartTax[] cartTaxestoInsert = new CartTax[]{};
            for (String sku : cartItemIdsBySKU.keySet()) {
                TaxDataFromExternalService rateAndAmountFromExternalService = rateAndAmountFromExternalServicePerSku.get(sku);
                if (rateAndAmountFromExternalService == null){
                    // return integrationStatusFailedWithCartValidationOutputError(
                    //     integStatus,
                    //     'The product with sku ' + sku + ' could not be found in the external system',
                    //     jobInfo,
                    //     cartId
                    // );
                }
                // If the sku was found in the external system, add a new CartTax line for that sku
                // The following fields from CartTax can be filled in:
                // Amount (required): Calculated tax amount.
                // CartItemId (required): ID of the cart item.
                // Description (optional): Description of CartTax.
                // Name (required): Name of the tax.
                // TaxCalculationDate (required): Calculation date for this tax line.
                // TaxRate (optional): The percentage value of the tax. Null if the tax is a flat amount.
                // TaxType (required): The type of tax, e.g. Actual or Estimated.
                CartTax tax = new CartTax( 
                    Amount = rateAndAmountFromExternalService.getAmount().setScale(2),
                    CartItemId = cartItemIdsBySKU.get(sku),
                    Name = rateAndAmountFromExternalService.getTaxName(),
                    TaxCalculationDate = Date.today(),
                    TaxRate = rateAndAmountFromExternalService.getRate(),
                    TaxType = 'Actual'
                );
                cartTaxestoInsert.add(tax);
            }
            insert(cartTaxestoInsert);
            resp.put('isSuccess', true);
        } catch(Exception e) {
            resp.put('isSuccess', false);
            resp.put('Error',e);
            // For testing purposes, this example treats exceptions as user errors, which means they are displayed to the buyer user.
            // In production you probably want this to be an admin-type error. In that case, throw the exception here
            // and make sure that a notification system is in place to let the admin know that the error occurred.
            // See the readme section about error handling for details about how to create that notification.
            // return integrationStatusFailedWithCartValidationOutputError(
            //     integStatus,
            //     'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage(),
            //     jobInfo,
            //     cartId
            // );
        }
        return resp;
    }

    public class TaxResult {
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
        public String ShippingCarrier;
        public String CarrierService;
        public Decimal ShippingTaxAmount;
    }

    public class OrderLine {
        public String LineID;
        public Decimal UnitTaxAmount;
        public Decimal AppliedRate;
        public String TaxCode;
        // public Decimal PricedQuantity;
        // public Decimal PricedListPrice;
        // public Decimal PricedSellingPrice;
        // public List<Discount> Discounts;
    }

    public class WrapperObject {
        public TaxResult TaxResult;
    }
}