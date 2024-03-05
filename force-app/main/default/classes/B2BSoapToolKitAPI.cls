/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-25-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/


global class B2BSoapToolKitAPI{
    
    global static String getCCSoapXMLBody(Map<String, String> params,List<CartItem> cartItems,commercepayments.AuthorizationRequest authRequest){ 
        Integer i = 0;
        String currencyIso = authRequest.currencyIsoCode;
         if(currencyIso == null) {
            currencyIso = UserInfo.getDefaultCurrency();
        }
        commercepayments.AuthApiPaymentMethodRequest paymentMethod = authRequest.paymentMethod;
        string strxml ='';
        strxml +=  '<?xml version="1.0" encoding="UTF-8"?>';
        strxml +=  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
        strxml +=  '<soapenv:Header>';
        strxml +=  '  <wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">';
        strxml +=  '   <wsse:UsernameToken>';
        strxml +=  '     <wsse:Username>'+params.get('userName')+'</wsse:Username>';
        strxml +=  '     <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+params.get('password')+'</wsse:Password>';
        strxml +=  '   </wsse:UsernameToken>';
        strxml +=  ' </wsse:Security>';
        strxml +=  ' </soapenv:Header>';
        strxml +=  '<soapenv:Body>';
        strxml +=  '  <requestMessage xmlns="urn:schemas-cybersource-com:transaction-data-1.129">';
        strxml +=  '    <merchantID>'+ params.get('merchantId') + '</merchantID>';
        strxml +=  '   <merchantReferenceCode>'+ params.get('mRefernceCode') +'</merchantReferenceCode>';
        strxml +=  '  <billTo>';
        strxml +=  '  <firstName>'+params.get('firstName')+'</firstName>';
        strxml +=  '  <lastName>'+params.get('lastName')+'</lastName>';
        strxml +=  ' <street1>'+params.get('street')+'</street1>';
        strxml +=  '  <city>'+params.get('city')+'</city>';
        strxml +=  '  <state>'+params.get('state')+'</state>';
        strxml +=  '  <postalCode>'+params.get('postalCode')+'</postalCode>';
        strxml +=  ' <country>'+params.get('country')+'</country>';
        strxml +=  '  <email>'+params.get('email')+'</email>';
        strxml +=  '</billTo>';
        //List of 
        for(CartItem cartItem: cartItems){
            
            strxml +=  ' <item id="'+i+'">';
           
            strxml +=  '   <unitPrice>'+cartItem.TotalLineAmount+'</unitPrice>';
          /*  strxml +=  '   <quantity>'+Integer.valueOf(cartItem.quantity)+'</quantity>'; */
            strxml +=  ' </item>';
            i++;
        }
        
        strxml +=  ' <purchaseTotals>';
        /*strxml +=  '   <currency>'+currencyIso+'</currency>';*/
        strxml +=  '   <currency>USD</currency>';
        strxml +=  ' </purchaseTotals>';
        
      //  commercepayments.CardPaymentMethodRequest cardPaymentMethod = authrequest.card​PaymentMethod;
        
        System.debug('paymentMethod format' + JSON.serialize(paymentMethod));
        
        //Map<String, Object> listJson = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(paymentMethod));
        
        //System.debug('strxml listJson' + JSON.serialize(listJson.get('cardPaymentMethod')));
        
        
        //Map<String, Object> cardObject  = (Map<String, Object>) listJson.get('cardPaymentMethod');
        
        //System.debug('cardObject ' + cardObject.get('cardNumber'));
        //System.debug('cardObject ' + cardObject.get('cardType')); // Card Name
        //System.debug('cardObject ' + cardObject.get('expiryMonth'));
        //System.debug('cardObject ' + cardObject.get('expiryYear'));
        
        //if(paymentMethod !=null) {
          //  if(paymentMethod.id!=null){
            
        //Id idToProccess = paymentMethod.id;  
         //if(idToProccess.getSObjectType() == CardPaymentMethod.SObjectType)
               // {
                
                //System.debug('cardPaymentMethod ' +cardPaymentMethod );
                
                //CardPaymentMethod cardObject = getCardObjectUsingId(idToProccess);
                
                //System.debug('cardObject ' +cardObject);
                
        /*strxml +=  ' <card>';
        strxml +=  '   <accountNumber>'+cardObject.get('cardNumber')+'</accountNumber>';
        strxml +=  '  <expirationMonth>'+cardObject.get('expiryMonth')+'</expirationMonth>';
        strxml +=  '  <expirationYear>'+cardObject.get('expiryYear')+'</expirationYear>';
        strxml +=  '   <cardType>'+changeCardtype((String)cardObject.get('cardType'))+'</cardType>';
        strxml +=  '</card>';
        
        
        /*strxml +=  ' <card>';
        strxml +=  '   <accountNumber>'+ cardPaymentMethod.cardNumber +'</accountNumber>';
        strxml +=  '  <expirationMonth>'+String.valueOf(cardPaymentMethod.expiryMonth)+'</expirationMonth>';
        strxml +=  '  <expirationYear>'+String.valueOf(cardPaymentMethod.expiryYear)+'</expirationYear>';
        strxml +=  '   <cardType>'+changeCardtype(String.valueOf(cardPaymentMethod.cardType))+'</cardType>';
        strxml +=  '</card>';*/
        //}
        //}
        //}
        
        
        strxml +=  ' <card>';
        strxml +=  '   <accountNumber>4111 1111 1111 1111</accountNumber>';
        strxml +=  '  <expirationMonth>12</expirationMonth>';
        strxml +=  '  <expirationYear>2025</expirationYear>';
        strxml +=  '   <cardType>001</cardType>';
        strxml +=  '</card>';
        
        
        
        strxml +=  ' <ccAuthService run="true"/>';
        
        strxml +=  ' </requestMessage>';
        strxml +=  ' </soapenv:Body>';
        strxml +=  '</soapenv:Envelope>';
        
        System.debug('strxml ' +strxml);
        
        return strxml;
    }
    
    
    
    global static String getCCSoapXMLTokenizeBody(Map<String, String> params,List<CartItem> cartItems,commercepayments.PaymentMethodTokenizationRequest tokenizeRequest){ 
        Integer i = 0;
        String currencyIso;
         if(currencyIso == null) {
            currencyIso = UserInfo.getDefaultCurrency();
        }
        commercepayments.CardPaymentMethodRequest cardPaymentMethod = tokenizeRequest.cardPaymentMethod;
        

        string strxml ='';
        strxml +=  '<?xml version="1.0" encoding="UTF-8"?>';
        strxml +=  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
        strxml +=  '<soapenv:Header>';
        strxml +=  '  <wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">';
        strxml +=  '   <wsse:UsernameToken>';
        strxml +=  '     <wsse:Username>'+params.get('userName')+'</wsse:Username>';
        strxml +=  '     <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+params.get('password')+'</wsse:Password>';
        strxml +=  '   </wsse:UsernameToken>';
        strxml +=  ' </wsse:Security>';
        strxml +=  ' </soapenv:Header>';
        strxml +=  '<soapenv:Body>';
        strxml +=  '  <requestMessage xmlns="urn:schemas-cybersource-com:transaction-data-1.129">';
        strxml +=  '    <merchantID>'+ params.get('merchantId') + '</merchantID>';
        strxml +=  '   <merchantReferenceCode>'+ params.get('mRefernceCode') +'</merchantReferenceCode>';
        strxml +=  '  <billTo>';
        strxml +=  '  <firstName>'+params.get('firstName')+'</firstName>';
        strxml +=  '  <lastName>'+params.get('lastName')+'</lastName>';
        strxml +=  ' <street1>'+params.get('street')+'</street1>';
        strxml +=  '  <city>'+params.get('city')+'</city>';
        strxml +=  '  <state>'+params.get('state')+'</state>';
        strxml +=  '  <postalCode>'+params.get('postalCode')+'</postalCode>';
        strxml +=  ' <country>'+params.get('country')+'</country>';
        strxml +=  '  <email>'+params.get('email')+'</email>';
        strxml +=  '</billTo>';
        //List of 
        for(CartItem cartItem: cartItems){            
            strxml +=  ' <item id="'+i+'">';           
            strxml +=  '   <unitPrice>'+cartItem.TotalLineAmount+'</unitPrice>';
            strxml +=  ' </item>';
            i++;
        }
        
        strxml +=  ' <purchaseTotals>';
        strxml +=  '   <currency>USD</currency>';
        strxml +=  ' </purchaseTotals>';
        strxml +=  ' <card>';
        strxml +=  '   <accountNumber>'+ cardPaymentMethod.cardNumber +'</accountNumber>';
        strxml +=  '  <expirationMonth>'+String.valueOf(cardPaymentMethod.expiryMonth)+'</expirationMonth>';
        strxml +=  '  <expirationYear>'+String.valueOf(cardPaymentMethod.expiryYear)+'</expirationYear>';
        strxml +=  '   <cardType>'+changeCardtype(String.valueOf(cardPaymentMethod.cardType))+'</cardType>';
        strxml +=  '</card>';
        
        strxml +=  ' <ccAuthService run="true"/>';
        
        strxml +=  ' </requestMessage>';
        strxml +=  ' </soapenv:Body>';
        strxml +=  '</soapenv:Envelope>';
        
        System.debug('strxml ' +strxml);
        
        return strxml;
    }
    
   public static String changeCardtype(String cardType){
        if(cardType=='Visa'){
            cardType='001';
        }
        else if(cardType=='MasterCard'){
            cardType='002';
        }
        else if(cardType=='AmericanExpress'){
            cardType='003';
        }
        else if(cardType=='Discover'){
            cardType='004';
        }
        else if(cardType=='DinersClub'){
            cardType='005';
        }
        else if(cardType=='JCB'){
            cardType='007';
        }
        
        return cardType;
    }

}