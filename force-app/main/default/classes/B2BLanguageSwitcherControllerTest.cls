@isTest
private class B2BLanguageSwitcherControllerTest {

    // Test data setup method to create custom metadata records
/*    @TestSetup
    static void setupTestData() {
        List<B2B_Language_Switcher__mdt> languages = new List<B2B_Language_Switcher__mdt>{
            new B2B_Language_Switcher__mdt(DeveloperName = 'TestLang1', B2B_Display_Text__c = 'Test Language 1', B2B_Active__c = true, B2B_Lang_Code__c = 'en_US', B2B_Sort_Order__c = 1),
            new B2B_Language_Switcher__mdt(DeveloperName = 'TestLang2', B2B_Display_Text__c = 'Test Language 2', B2B_Active__c = true, B2B_Lang_Code__c = 'fr_CA', B2B_Sort_Order__c = 2)
        };
        insert languages;
    }
*/
    @isTest
    static void testGetLanguages() {
        Map<String, Object> inputData = new Map<String, Object>{
            B2BLanguageSwitcherConstant.IS_GUEST => false
        };
         // Test B2BLanguageSwitcherHelper's Method   
        Map<String, Object> result = B2BLanguageSwitcherHelper.getLanguages(inputData); 
        
        // Test B2BLanguageSwitcherController's Method 
        String result2 = B2BLanguageSwitcherController.getLanguages(inputData);
        B2BLanguageSwitcherController.getLanguages(null);
        
        //System.assertTrue((Boolean) result.get(B2BLanguageSwitcherConstant.IS_SUCCESS), 'Expected successful response');
        System.assert(result.containsKey(B2BLanguageSwitcherConstant.LANGUAGES), 'Languages should be present in the result');
        List<B2BLanguageSwitcherVO> langList = (List<B2BLanguageSwitcherVO>) result.get(B2BLanguageSwitcherConstant.LANGUAGES);
        //System.assertEquals(2, langList.size(), 'Expected 2 languages in the result');
    }

    @isTest
    static void testUpdateUserLanguage() {
        Map<String, Object> inputData = new Map<String, Object>{
            B2BLanguageSwitcherConstant.LANGUAGE_CODE => 'en_US'
        };
            
        // Test B2BLanguageSwitcherHelper's Method 
        B2BLanguageSwitcherHelper.updateUserLanguage(inputData);
        
        // Test B2BLanguageSwitcherController's Method
        B2BLanguageSwitcherController.updateUserLanguage(null); 
        String result2 = B2BLanguageSwitcherController.updateUserLanguage(inputData);

        User u = [SELECT LanguageLocalekey FROM User WHERE Id =: UserInfo.getUserId()];
        System.assertEquals('en_US', u.LanguageLocalekey, 'Expected the user language to be updated');
    }

    // You can also add negative tests or edge cases as necessary.
}