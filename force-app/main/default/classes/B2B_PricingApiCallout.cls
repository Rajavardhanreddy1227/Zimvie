public with sharing class B2B_PricingApiCallout extends Retryable{

    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PRICINGAPI_CALLOUT);

    private final String body;
    private final String endpointUrl;
    private final Map<String,Object> reqBodyMap;
    private final List<B2BCartService.OrderLine> respOrderLineList;

    public B2B_PricingApiCallout(String body,String endpointUrl, Map<String,Object> reqBodyMap, List<B2BCartService.OrderLine> respOrderLineList) {
        try{
            this.body = body;
            this.endpointUrl = endpointUrl;
            this.reqBodyMap = reqBodyMap;
            this.respOrderLineList = respOrderLineList;
            retryScheduleInMinutes = new List<Integer>{1, 5, 25, 60, 2*60};
        }catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }
    }

    public override JobResult startJob() {
        try{
            // log.d('Started MockCallout');
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setTimeout(60000);
            request.setEndpoint(this.endpointUrl);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/xml');
            //request.setHeader('Accept', 'application/json');
            request.setBody(this.body);
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                // API call was successful
                String xmlResponse = response.getBody();
                // Parse the XML
                Dom.Document doc = new Dom.Document();
                doc.load(xmlResponse);
    
                // Create a wrapper object
                B2BCartService.WrapperObject wrapperObj = new B2BCartService.WrapperObject();
    
                // Parse PricingResult
                Dom.XmlNode pricingResultNode = doc.getRootElement();
                wrapperObj.PricingResult = new B2BCartService.PricingResult();
    
                // Parse RequestResult
                Dom.XmlNode requestResultNode = pricingResultNode.getChildElement('RequestResult', null);
                wrapperObj.PricingResult.RequestResult = new B2BCartService.RequestResult();
                wrapperObj.PricingResult.RequestResult.Status = requestResultNode.getChildElement('Status', null).getText();
                wrapperObj.PricingResult.RequestResult.Message = requestResultNode.getChildElement('Message', null).getText();
    
                // Parse OrderHeader
                Dom.XmlNode orderHeaderNode = pricingResultNode.getChildElement('OrderHeader', null);
                wrapperObj.PricingResult.OrderHeader = new B2BCartService.OrderHeader();
                wrapperObj.PricingResult.OrderHeader.HeaderID = orderHeaderNode.getAttribute('HeaderID',null);
                wrapperObj.PricingResult.OrderHeader.CurrencyCode = orderHeaderNode.getChildElement('CurrencyCode', null).getText();
    
                // Parse OrderLines
                List<Dom.XmlNode> orderLineNodes = pricingResultNode.getChildElement('OrderLines', null).getChildElements();
                wrapperObj.PricingResult.OrderLines = new List<B2BCartService.OrderLine>();
                for (Dom.XmlNode orderLineNode : orderLineNodes) {
                    B2BCartService.OrderLine orderLine = new B2BCartService.OrderLine();
                    orderLine.LineID = orderLineNode.getAttribute('LineID',null);
                    orderLine.PricedQuantity = Decimal.valueOf(orderLineNode.getChildElement('PricedQuantity', null).getText());
                    orderLine.PricedListPrice = Decimal.valueOf(orderLineNode.getChildElement('PricedListPrice', null).getText());
                    orderLine.PricedSellingPrice = Decimal.valueOf(orderLineNode.getChildElement('PricedSellingPrice', null).getText());
    
                    // Parse Discounts
                    Dom.XmlNode discountXmlNode = orderLineNode.getChildElement('Discounts', null);
                    if(discountXmlNode != null){
                        List<Dom.XmlNode> discountNodes = orderLineNode.getChildElement('Discounts', null).getChildElements();
                        orderLine.Discounts = new List<B2BCartService.Discount>();
                        for (Dom.XmlNode discountNode : discountNodes) {
                            B2BCartService.Discount discount = new B2BCartService.Discount();
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
                    if(wrapperObj?.PricingResult?.OrderLines != null){
                        B2BCartService.updateAllCartItem(this.reqBodyMap, this.respOrderLineList);
                    }else{
                    }
                    
                }
            } else {
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