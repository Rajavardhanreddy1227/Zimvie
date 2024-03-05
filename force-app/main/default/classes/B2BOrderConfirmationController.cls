/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 09-17-2023
 * @last modified by  : Gaurav Setia
**/
public with sharing class B2BOrderConfirmationController {
    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.CART_MODULE);
    private static final String CLASSNAME = 'B2BOrderConfirmationController';
    private static final String MODULE_NAME = 'Order Module';

    @AuraEnabled
    public static Map<String,Object> getOrderProductSummary(Map<String,Object> mapParams){
        String methodName = 'getOrderProductSummary';
        String supportData = '';
        try{
            B2BOrderConfirmationService.getOrderProductSummary(mapParams);
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
    public static Map<String,Object> getAddressInformation(Map<String,Object> mapParams){
        String methodName = 'getAddressInformation';
        String supportData = '';
    
        try{
            B2BOrderConfirmationService.getAddressInformation(mapParams); 
          
        }catch (Exception ex) {
            logger.error(ex);
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(B2BConstants.IS_SUCCESS,false);
            mapParams.put(B2BConstants.MESSAGE,ex.getMessage());
          
        }finally
        {
            logger.flush();
        }
        return mapParams;
    }

    @AuraEnabled
    public static Map<String,Object> sendOrderConfirmEmail(Map<String,Object> mapParams){
        String methodName = 'sendOrderConfirmEmail';
        String supportData = '';
    
        try{
            B2BOrderConfirmationService.sendOrderConfirmEmail(mapParams); 
          
        }catch (Exception ex) {
            logger.error(ex);
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(B2BConstants.IS_SUCCESS,false);
            mapParams.put(B2BConstants.MESSAGE,ex.getMessage());
          
        }finally
        {
            logger.flush();
        }
        return mapParams;
    }
}