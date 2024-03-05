/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 09-17-2023
 * @last modified by  : Gaurav Setia
**/
public with sharing class B2BOrderConfirmationService {
    
    private static final String CLASSNAME = 'B2BOrderConfirmationService';
    private static final String MODULE_NAME = 'Order Module';

    public static Map<String,Object> getOrderProductSummary(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        if(mapParams.containsKey(B2BConstants.ORDER_SUMMARY_NUMBER) && String.isNotBlank((String)mapParams.get(B2BConstants.ORDER_SUMMARY_NUMBER))){
            mapParams = B2BOrderConfirmationHelper.getOrderProductSummary(mapParams);
            isSuccess = true;
        }else{
            message = 'Invalid Request.'; 
        }
        mapParams.put(B2BConstants.IS_SUCCESS,isSuccess);
        mapParams.put(B2BConstants.MESSAGE,message);
        return mapParams;
    }

    public static Map<String,Object> getAddressInformation(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        if(mapParams.containsKey(B2BConstants.ORDER_SUMMARY_NUMBER) && String.isNotBlank((String)mapParams.get(B2BConstants.ORDER_SUMMARY_NUMBER))){
            mapParams = B2BOrderConfirmationHelper.getAddressInformation(mapParams);
            isSuccess = true;
        }else{
            message = 'Invalid Request.';
        }
        mapParams.put(B2BConstants.IS_SUCCESS,isSuccess);
        mapParams.put(B2BConstants.MESSAGE,message);
        return mapParams;
    }

    public static Map<String,Object> sendOrderConfirmEmail(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        if(mapParams != null && mapParams.containsKey(B2BConstants.ORDER_SUMMARY_NUMBER) && String.isNotBlank((String)mapParams.get(B2BConstants.ORDER_SUMMARY_NUMBER))){
            isSuccess = B2BOrderConfirmationHelper.sendOrderConfirmEmail(mapParams);
        }else{
            message = 'Error in sending email.';
        }
        mapParams.put(B2BConstants.IS_SUCCESS,isSuccess);
        mapParams.put(B2BConstants.MESSAGE,message);
        return mapParams;
    }
}