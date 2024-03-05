public with sharing class B2BOrderServiceRetryable extends Retryable {
    
    private final String body;
    private final String orderSummId;

    public B2BOrderServiceRetryable(String body,String orderSummId) {
        this.body = body;
        this.orderSummId = orderSummId;
        retryScheduleInMinutes = new List<Integer>{1, 5, 10, 30, 60}; //OVERRIDE DEFAULT RETRY SCHEDULE
    }
    
    public override JobResult startJob() {
        system.debug('executing job');
        String endpointUrl = 'https://dev-ecomm.zimvie.com/ords/psp_datahub/datahub/ecmoccord';
        HttpRequest request = new HttpRequest();
        request.setTimeout(60000);
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/xml');
        request.setBody(this.body);

        HttpResponse response = new Http().send(request);
        System.debug('response---- '+response);
        System.debug('responseBody---- '+response.getBody());
        
        Integer httpResponseCode = response.getStatusCode();
        switch on httpResponseCode{
            when 200,201{
                String xmlResponse = response.getBody();
                Dom.Document doc = new Dom.Document();
                doc.load(xmlResponse);

                Dom.XmlNode root = doc.getRootElement();
                Dom.XmlNode body = root.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                Dom.XmlNode acknowledgeOrder = body.getChildElement('AcknowledgeOrder', 'http://www.ibm.com/xmlns/prod/commerce/order');

                //OrderEnvelope envelope = new OrderEnvelope();
                //envelope.ord = new OrderEnvelope.AcknowledgeOrder();

                Dom.XmlNode applicationArea = acknowledgeOrder.getChildElement('ApplicationArea', 'http://www.openapplications.org/oagis/9');
                Dom.XmlNode creationDateTime = applicationArea.getChildElement('CreationDateTime', 'http://www.openapplications.org/oagis/9');
                //envelope.ord.DataArea = new OrderEnvelope.DataArea();
                //envelope.ord.DataArea.Order = new OrderEnvelope.OrderHeader();

                //envelope.ord.ApplicationArea = new OrderEnvelope.ApplicationArea();
                //envelope.ord.ApplicationArea.CreationDateTime = DateTime.valueOf(creationDateTime.getText().tolowercase().replace('t',' '));

                Dom.XmlNode orderHeader = acknowledgeOrder.getChildElement('DataArea', 'http://www.ibm.com/xmlns/prod/commerce/order')
                    .getChildElement('Order', 'http://www.ibm.com/xmlns/prod/commerce/order')
                    .getChildElement('OrderHeader', 'http://www.ibm.com/xmlns/prod/commerce/order');
                system.debug('orderHeader='+orderHeader);
                Dom.XmlNode orderIdentifier = orderHeader.getChildElement('OrderIdentifier','http://www.ibm.com/xmlns/prod/commerce/foundation');
                //envelope.ord.DataArea.Order.OrderID = orderIdentifier.getChildElement('OrderID', 'http://www.ibm.com/xmlns/prod/commerce/foundation').getText();
                //envelope.ord.DataArea.Order.ExternalOrderID = orderIdentifier.getChildElement('ExternalOrderID', 'http://www.ibm.com/xmlns/prod/commerce/foundation').getText();

                String OracleOrderNumber = orderIdentifier.getChildElement('OrderID', 'http://www.ibm.com/xmlns/prod/commerce/foundation').getText();
                String ExternalOrderID = orderIdentifier.getChildElement('ExternalOrderID', 'http://www.ibm.com/xmlns/prod/commerce/foundation').getText();
                
                
                OrderSummary objOrd = new OrderSummary(Id=orderSummId);
                objOrd.OracleOrderId__c = ExternalOrderID;
                objOrd.OracleOrderNumber__c = OracleOrderNumber;
                objOrd.Sync_to_Oracle__c = true;
                update objOrd;

                return JobResult.success(response.getBody());
            }
            when 401{
                return JobResult.actionRequired(response.getBody());
            }
            when else {
                return JobResult.retry(response.getBody());
            }
        }
    }
}