public with sharing class B2BCartController {
     private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.ORDER_MODULE);
    private static final String CLASSNAME = 'B2BCartController';
    private static final String MODULE_NAME = 'Cart Module';

      @AuraEnabled
    public static Map<String,Object> getCpnFromCart(Map<String,Object> mapParams){
        String methodName = 'getCpnFromCart';
        String supportData = '';
        
        try{
            B2BCartService.getCpnFromCart(mapParams);
          
        }catch (Exception ex) {
            logger.error(ex);
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(B2BConstants.IS_SUCCESS,false);
            mapParams.put(B2BConstants.MESSAGE,ex.getMessage());
            
        }
         finally{
            logger.flush();
        }
        return mapParams;
    }
    @AuraEnabled
    public static Boolean getEnrollStatus(Map<String,Object> mapParams){
        Boolean enrolled= False;
        try{
        String effectiveAccountId = String.valueOf(mapParams.get('effectiveAccountId'));
        
        Account acc= [SELECT Id,Enrollment_Status__c FROM Account WHERE Id=:effectiveAccountId];
        if(acc!=null && acc.Enrollment_Status__c =='Enrolled'){
            enrolled =True;
        }
        }
        catch (Exception ex) {
            logger.error(ex);
        }
         finally{
            logger.flush();
        }
        return enrolled;
    }


    @AuraEnabled
    public static Map<String,Object> getRMACartDetail(Map<String,Object> mapParams){
        Map<String,Object> resp = new Map<String,Object>();
        try {
            resp.put(B2BConstants.IS_SUCCESS,true);
            Id cartId = String.valueOf(mapParams.get('cartId'));
            WebCart objCart = [Select Id,Type__c from WebCart where Id=:cartId];
            Boolean isRMACart = objCart.Type__c != null ? objCart.Type__c.indexOf('RMA') != -1 : false;
            resp.put('IsRMACart',isRMACart);
        } catch (Exception e) {
            resp.put(B2BConstants.IS_SUCCESS,false);
            resp.put('Error',e);
              logger.error(e);
            //throw new AuraHandledException(e.getMessage());
        }
          finally{
            logger.flush();
        }

        return resp;
    }

    @AuraEnabled
    public static Map<String,Object> calculateDiscountOnItem(Map<String,Object> mapParams){
        Map<String,Object> resp = new Map<String,Object>();
        try {
            resp = B2BCartService.calculateDiscountOnItem(mapParams);
            resp.put(B2BConstants.IS_SUCCESS,true);
            Id cartItemId = String.valueOf(mapParams.get('cartItemId'));
            Boolean isRMACart = [Select CartId,Cart.Type__c from CartItem where Id=:cartItemId].Cart.Type__c?.indexOf('RMA') != -1;
            resp.put('IsRMACart',isRMACart);
        } catch (Exception e) {
            resp.put(B2BConstants.IS_SUCCESS,false);
            resp.put('Error',e);
              logger.error(e);
            //throw new AuraHandledException(e.getMessage());
        }
          finally{
            logger.flush();
        }

        return resp;
    }

    @AuraEnabled
    public static Map<String,Object> calculateDiscountOnCart(Map<String,Object> mapParams){
        Map<String,Object> resp = new Map<String,Object>();
        try {
            resp = B2BCartService.calculateDiscountOnCart(mapParams);
            resp.put(B2BConstants.IS_SUCCESS,true);
            // Id cartItemId = String.valueOf(mapParams.get('cartItemId'));
            // Boolean isRMACart = [Select CartId,Cart.Type__c from CartItem where Id=:cartItemId].Cart.Type__c?.indexOf('RMA') != -1;
            // resp.put('IsRMACart',isRMACart);
        } catch (Exception e) {
            resp.put(B2BConstants.IS_SUCCESS,false);
            resp.put('Error',e);
              logger.error(e);
            //throw new AuraHandledException(e.getMessage());
        }
          finally{
            logger.flush();
        }

        return resp;
    }

    @AuraEnabled
    public static Map<String,Object> deleteCartShippingAndTax(Map<String,Object> mapParams){
        Map<String,Object> resp = new Map<String,Object>();
        try {
            resp = B2BCartService.deleteCartShippingAndTax(mapParams);
            resp.put(B2BConstants.IS_SUCCESS,true);
            // Id cartItemId = String.valueOf(mapParams.get('cartItemId'));
            // Boolean isRMACart = [Select CartId,Cart.Type__c from CartItem where Id=:cartItemId].Cart.Type__c?.indexOf('RMA') != -1;
            // resp.put('IsRMACart',isRMACart);
        } catch (Exception e) {
            resp.put(B2BConstants.IS_SUCCESS,false);
            resp.put('Error',e);
              logger.error(e);
            //throw new AuraHandledException(e.getMessage());
        }
          finally{
            logger.flush();
        }

        return resp;
    }
}