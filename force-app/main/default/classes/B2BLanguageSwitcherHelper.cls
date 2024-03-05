/**
 * @description       : 
 * @author            : Akash Arora
 * @group             : 
 * @last modified on  : 26-05-2023
 * @last modified by  : Akash Arora
**/
public with sharing class B2BLanguageSwitcherHelper {

    private static final String CLASSNAME = 'B2BLanguageSwitcherHelper';

    public static Map<String, Object> getLanguages(Map<String, Object> dataMap) {
        //String methodName = 'getLanguages';
        Boolean isSuccess = false;

        if(dataMap != null && dataMap.containsKey(B2BLanguageSwitcherConstant.IS_GUEST) && 
            dataMap.get(B2BLanguageSwitcherConstant.IS_GUEST) != null) {

                //if(!(Boolean)dataMap.get(B2BLanguageSwitcherConstant.IS_GUEST)) {
                User user = [SELECT Id, LanguageLocalekey FROM User WHERE Id =:UserInfo.getUserId()];
                //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BLoggingConstant.MESSAGING_VALUE , JSON.serialize(user));

                List<B2BLanguageSwitcherVO> langList = new List<B2BLanguageSwitcherVO>();
                for(B2B_Language_Switcher__mdt lang : [SELECT Id,DeveloperName,B2B_Display_Text__c,B2B_Active__c,B2B_Lang_Code__c,B2B_Sort_Order__c From B2B_Language_Switcher__mdt WHERE B2B_Active__c = true ORDER BY B2B_Sort_Order__c ASC]) {
                    B2BLanguageSwitcherVO ob = new B2BLanguageSwitcherVO();
                    ob.language = lang.B2B_Display_Text__c;
                    ob.code = lang.B2B_Lang_Code__c;
                    if(user.LanguageLocaleKey == lang.B2B_Lang_Code__c) {
                        ob.selected = true;
                    } else {
                        ob.selected = false;
                    }
                    langList.add(ob);
                }
                dataMap.put(B2BLanguageSwitcherConstant.LANGUAGES, langList);
                isSuccess = true;
                //}
        }
        dataMap.put(B2BLanguageSwitcherConstant.IS_SUCCESS, isSuccess);
        return dataMap; 
    }
    
    public static void updateUserLanguage(Map<String, Object> dataMap) {
        String methodName = 'updateUserLanguage';

        if(dataMap != null && dataMap.containsKey(B2BLanguageSwitcherConstant.LANGUAGE_CODE) &&
            dataMap.get(B2BLanguageSwitcherConstant.LANGUAGE_CODE) != null) {
            String language = (String)dataMap.get(B2BLanguageSwitcherConstant.LANGUAGE_CODE);
            User user = new User(Id = UserInfo.getUserId());
            user.LanguageLocalekey = language;
            update user;
        } 
    }
}