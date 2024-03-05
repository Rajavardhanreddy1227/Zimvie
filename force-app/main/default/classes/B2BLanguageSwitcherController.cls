/**
 * @description       : 
 * @author            : Akash Arora
 * @group             : 
 * @last modified on  : 26-05-2023
 * @last modified by  : Akash Arora
**/
public with sharing class B2BLanguageSwitcherController {

    //private static final String CLASSNAME = 'B2BLanguageSwitcherController';
    //private static final String STOREFRONT = 'CaseWare';
    //private static final String MODULE_NAME = 'Language Switcher Module';
    
    @AuraEnabled(cacheable = true)
    public static String getLanguages(Map<String,Object> dataMap){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        String methodName = 'getLanguages';
        String supportData = '';
        try {
            //B2BLogger.log(LoggingLevel.DEBUG, CLASSNAME, methodName, B2BLoggingConstant.MESSAGING_ENTRY, 'Started');
            dataMap = B2BLanguageSwitcherHelper.getLanguages(dataMap);
            //B2BLogger.log(LoggingLevel.DEBUG, CLASSNAME, methodName, B2BLoggingConstant.MESSAGING_EXIT, 'End');
        } catch (Exception ex) {
            dataMap = dataMap == null ? new Map<String, Object>() : dataMap ;
            dataMap.put(B2BLanguageSwitcherConstant.IS_SUCCESS, false);
            dataMap.put(B2BLanguageSwitcherConstant.MESSAGE, ex.getMessage());
            //B2BExceptionLogs.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
            logger.error(ex);
        } finally {
            //B2BLogger.handleApplicationLogging(dataMap);
            logger.flush();
        }
        system.debug('dataMap='+dataMap);
        return JSON.serialize(dataMap);
    }

    @AuraEnabled
    public static String updateUserLanguage(Map<String,Object> dataMap){
        String methodName = 'updateUserLanguage';
        String supportData = '';
        try {
            //B2BLogger.log(LoggingLevel.DEBUG, CLASSNAME, methodName, B2BLoggingConstant.MESSAGING_ENTRY, 'Started');
            B2BLanguageSwitcherHelper.updateUserLanguage(dataMap);
            dataMap.put(B2BLanguageSwitcherConstant.IS_SUCCESS, true);
            //B2BLogger.log(LoggingLevel.DEBUG, CLASSNAME, methodName, B2BLoggingConstant.MESSAGING_EXIT, 'End');
        } catch (Exception ex) {
            dataMap = dataMap == null ? new Map<String, Object>() : dataMap ;
            dataMap.put(B2BLanguageSwitcherConstant.IS_SUCCESS, false);
            dataMap.put(B2BLanguageSwitcherConstant.MESSAGE, ex.getMessage());
            //B2BExceptionLogs.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        } finally {
            //B2BLogger.handleApplicationLogging(dataMap);
        }
        return JSON.serialize(dataMap);
         
    }

    @AuraEnabled
    public static String getLoggedInUserLanguage(){
        return userInfo.getLanguage();
    }
}