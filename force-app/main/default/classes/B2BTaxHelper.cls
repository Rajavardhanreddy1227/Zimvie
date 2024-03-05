public with sharing class B2BTaxHelper {

    public static void deleteExitingCartTaxes(Id cartId){
        List<CartTax> cartTaxes = B2BCartSelector.queryCartTaxDetails(cartId);
        if(!cartTaxes.isEmpty())
        {
            delete cartTaxes;
        }
    }
    public static Map<String,Object> getTaxrate(Id cartId){
        Boolean isSuccess = false;
        String message = '';
        Map<String,Object> mapParams = new Map<String,Object>();
        WebCart cart = B2BCartSelector.queryCartDetails(new List<String>{cartId});
        if(cart!=null && cart.CartDeliveryGroups != null && !cart.CartDeliveryGroups.isEmpty() && cart.CartItems != null){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:B2BOracleCallout');//TODO named credentials
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/xml');
            request.setHeader('Accept', '*/*');
            String body = getTaxBody(cart);
            System.debug('body '+body);
            request.setBody(body);
            HttpResponse response = http.send(request);
            System.debug('response '+response);
            
        }else{
            isSuccess = false;
            message = 'Invalid CartId.';
        }
        mapParams.put(B2BConstants.IS_SUCCESS,isSuccess);
        mapParams.put(B2BConstants.MESSAGE,message);
        return mapParams;

    }

    public static string getTrackingGUID(Id cartId){
        String hashString = UserInfo.getUserId() + '__' + UserInfo.getOrganizationId() +cartId+
                String.valueOf(Datetime.now().formatGmt('YYYYMMddHHmmss'));
        Blob hash = Crypto.generateDigest('MD5' , Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        hexDigest = hexDigest.substring(0, 8);
        return hexDigest;
    }

    public static string getTaxBody(WebCart cart){
        String body = '<?xml version="1.0" encoding="UTF-8"?><TaxRequest TrackingGUID="10bf8321-5849-4b19-86f3-544b1f7e6e9d"><OrderHeader HeaderID="184018"><OrderNumber>184018</OrderNumber><CustomerID>417054</CustomerID><CustomerNumber>418762</CustomerNumber><ShiptoLocationID>1465532</ShiptoLocationID><ShiptoName/><ShippingCarrier>FedEx</ShippingCarrier><CarrierService>FED1PM</CarrierService><ShippingCharge>21.00</ShippingCharge><CurrencyCode>USD</CurrencyCode></OrderHeader><OrderLines><OrderLine LineID="617487"><LineNumber>1</LineNumber><ItemID>3074457345616683830</ItemID><ItemNumber>IILA20</ItemNumber><OrderedQuantity>3.0</OrderedQuantity><UnitSellingPrice>37</UnitSellingPrice></OrderLine><OrderLine LineID="617488"><LineNumber>2</LineNumber><ItemID>3074457345616683831</ItemID><ItemNumber>IILAW5</ItemNumber><OrderedQuantity>3.0</OrderedQuantity><UnitSellingPrice>37</UnitSellingPrice></OrderLine></OrderLines></TaxRequest>';

        // body += '<?xml version="1.0" encoding="UTF-8"?>';
        // body += '<TaxRequest TrackingGUID="'+getTrackingGUID(cart.Id)+'">';
        // body += '<OrderHeader HeaderID="'+cart.Id+'">';
        // body += '<OrderNumber>'+cart.Id+'</OrderNumber>';
        // body += '<CustomerID>417054</CustomerID>';//TODO
        // body += '<CustomerNumber>418762</CustomerNumber>';//TODO

        // body += '<ShiptoLocationID>1465532</ShiptoLocationID>';
        // body += '<ShiptoName/>';
        // body += '<ShippingCarrier>FedEx</ShippingCarrier>';
        // body += '<CarrierService>FED1PM</CarrierService>';
        // body += '<ShippingCharge>21.00</ShippingCharge> ';
        // body += ' <CurrencyCode>'+cart.CurrencyIsoCode+'</CurrencyCode>';
        // body += '</OrderHeader>';
        // body += '<OrderLines>';
        // Integer i = 1;
        // for(cartItem ci : cart.cartItems){
        //     if(String.isNotBlank(ci.Sku)){
        //         body += '<OrderLine LineID="'+ci.Id+'">';
        //         body += '<LineNumber>'+i+'</LineNumber>';
        //         body += '<ItemID>'+ci.Id+'</ItemID>';
        //         body += '<ItemNumber>'+ci.Sku+'</ItemNumber>';
        //         body += '<OrderedQuantity>'+ci.Quantity+'</OrderedQuantity>';
        //         body += '<UnitSellingPrice>'+ci.UnitAdjustedPrice+'</UnitSellingPrice>';
        //         body += '</OrderLine>';
        //         i++;
        //     }
        //  }
         body += '</OrderLines>';
         body +='</TaxRequest>';
        return body;
    }

}