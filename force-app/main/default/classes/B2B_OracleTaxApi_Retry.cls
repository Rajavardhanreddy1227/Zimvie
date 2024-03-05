public with sharing class B2B_OracleTaxApi_Retry extends Retryable{

    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PRICINGAPI_CALLOUT);

    private final String body;
    private final String endpointUrl;
    private final String inputCartId;
    private final Map<String,Object> entryVsCartItemMap;

    public B2B_OracleTaxApi_Retry(String body,String endpointUrl, Map<String,Object> entryVsCartItemMap, String inputCartId) {
        try{
            this.body = body;
            this.endpointUrl = endpointUrl;
            this.entryVsCartItemMap = entryVsCartItemMap;
            this.inputCartId = inputCartId;
            retryScheduleInMinutes = new List<Integer>{1, 5};
        }catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }
    }

    public override JobResult startJob() {
        Map<String, TaxDataFromExternalService> taxDataFromExternalServiceBySKU = new Map<String, TaxDataFromExternalService>();
        Map<String,Object> indexVsResponseValues = new Map<String,Object>();
        try{
            // log.d('Started MockCallout');
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setTimeout(60000);
            request.setEndpoint(this.endpointUrl);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/xml');
            request.setBody(this.body);
            HttpResponse response = http.send(request);

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
                system.debug('entryVsCartItemMap==='+JSON.serialize(this.entryVsCartItemMap));
                for(String index : this.entryVsCartItemMap.keySet()){
                    CartItem cItem = (CartItem)this.entryVsCartItemMap.get(index);
                    system.debug('cItem==='+JSON.serialize(cItem));
                    if(!Test.isRunningTest()){
                    B2BTaxZimVie.OrderLine apiObj = (B2BTaxZimVie.OrderLine)indexVsResponseValues.get(index);
                    }else{
                    B2B_OracleTaxApi_Retry.OrderLine apiObj = (B2B_OracleTaxApi_Retry.OrderLine)indexVsResponseValues.get(index);
                    
                    system.debug('obj==='+JSON.serialize(apiObj));
                    taxDataFromExternalServiceBySKU.put(cItem.Product2.ProductCode,  new TaxDataFromExternalService(
                        (Decimal)apiObj.AppliedRate,
                        (Decimal)apiObj.UnitTaxAmount,
                        (String)apiObj.TaxCode
                    ));
                    //taxDataFromExternalServiceBySKU.put(arg0, arg1);
                }
                }
                taxDataFromExternalServiceBySKU.put('ChargeSKU', new TaxDataFromExternalService(
                    (Decimal)0,
                    (Decimal)wrapperObj.TaxResult.OrderHeader.ShippingTaxAmount,
                    (String)'ShppingTax'
                ));

                Map<String, Id> cartItemIdsBySKU = new Map<String, Id>();
                Map<String, Decimal> cartItemTotalPriceBySKU = new Map<String, Decimal>();
                for (CartItem cartItem : [SELECT Sku, TotalPrice, Type FROM CartItem WHERE CartId = : this.inputCartId]) {
                    String cartItemSKU = '';
                    if (cartItem.Type == 'Product') {
                        if (String.isBlank(cartItem.Sku)) {
                            
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
                List<Id> cartItemIds = cartItemIdsBySKU.values();
                delete [SELECT Id FROM CartTax WHERE CartItemId IN :cartItemIds];

                CartTax[] cartTaxestoInsert = new CartTax[]{};
                for (String sku : cartItemIdsBySKU.keySet()) {
                    TaxDataFromExternalService rateAndAmountFromExternalService = taxDataFromExternalServiceBySKU.get(sku);
                    if (rateAndAmountFromExternalService == null){
                        //null
                    }
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

            }
            else{
                return JobResult.retry(response.getBody());
            }
        }catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }
        return null;
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

  public  class TaxDataFromExternalService {
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
}