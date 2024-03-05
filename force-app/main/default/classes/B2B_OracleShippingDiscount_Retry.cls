public with sharing class B2B_OracleShippingDiscount_Retry extends Retryable{

    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PRICINGAPI_CALLOUT);

    private final String body;
    private final String endpointUrl;
    private final String cartId;

    public B2B_OracleShippingDiscount_Retry(String body,String endpointUrl, String cartId) {
        try{
            this.body = body;
            this.endpointUrl = endpointUrl;
            this.cartId = cartId;
            retryScheduleInMinutes = new List<Integer>{1, 5};
        }catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }
    }

    public override JobResult startJob() {
        Map<String,Object> resp = new Map<String,Object>();
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

            if(response.getStatusCode() == 200){
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
                    if(wrapperObj?.PricingResult?.OrderHeader?.DiscountedShippingCharge != null){
                        Decimal discountAmnt = (wrapperObj?.PricingResult?.OrderHeader?.DiscountedShippingCharge) * -1;
                        b2B_checkoutAddressController.updateShippingCartItem(this.cartId, discountAmnt);
                    }
                }
            }else{
                return JobResult.retry(response.getBody());
            }
        }catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }
        return null;
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
}