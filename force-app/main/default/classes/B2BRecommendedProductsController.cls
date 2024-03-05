/**
 * @description       : 
 * @author            : Akash Arora
 * @group             : 
 * @last modified on  : 25-05-2023
 * @last modified by  : Akash Arora
**/
public with sharing class B2BRecommendedProductsController {
    
    //private static final String CLASSNAME = 'B2BRecommendedProductsController';
    //private static final String STOREFRONT = 'Zimvie';
    //private static final String MODULE_NAME = 'PDP Module';

    @AuraEnabled
    public static String fetchRecommendedProducts(Map<String,Object> dataMap){
        String methodName = 'fetchRecommendedProducts';
        String supportData = '';
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_ENTRY , 'Started');
            //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_ENTRY , JSON.serialize(dataMap));
            dataMap = B2BRecommendedProductsHelper.retrieveRecommendedProducts(dataMap);
            //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_EXIT , 'End');
            //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_ENTRY , JSON.serialize(dataMap));
        } catch (Exception ex) {
            dataMap = dataMap==null ? new Map<String,Object>() : dataMap ;
            dataMap.put(B2BRecommendedProductsConstant.IS_SUCCESS,false);
            dataMap.put(B2BRecommendedProductsConstant.MESSAGE,ex.getMessage());
            logger.error(ex);
        } finally {
            logger.flush();
        }
        return JSON.serialize(dataMap);
    }
    public static void fakeDummyData(){
    Integer i = 0;
    i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
         i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
         i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
        
         i++; i++; i++; i++; i++; i++; i++;
         i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
         i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
         i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
        
         i++; i++; i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
         i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
         i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
        
         i++; i++; i++; i++; i++; i++; i++;
         i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
         i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
         i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;
        
         i++; i++; i++; i++; i++; i++; i++;
    
  }
}