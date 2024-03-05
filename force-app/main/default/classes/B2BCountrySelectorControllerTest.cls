@isTest
public class B2BCountrySelectorControllerTest {

    @isTest static void testFetchLocalesForNormalUser() {
        // Test as Non Guest User
        Test.startTest();
        String result = B2BCountrySelectorController.fetchLocales();
        Test.stopTest();
        
        //List<B2BCountrySelectorController.countryWrap> countryList = (List<B2BCountrySelectorController.countryWrap>) JSON.deserialize(result, List<B2BCountrySelectorController.countryWrap>.class);
        
        // Asserts
        //System.assertEquals(5, countryList.size(), 'Expected 5 countries for guest user');
        //System.assertEquals('United States', countryList[0].label);
        //System.assertEquals('Canada', countryList[1].label);
        // ... Add assertions for other countries too
    }
    
    @isTest static void testFetchLocalesForGuestUser() {
            
        	Profile p = [SELECT Id from Profile WHERE Name = 'Guest License User' LIMIT 1];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
            Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
            String uniqueName = orgId + dateString + RandomId;
            User gu = new User(firstname = 'Guest',
                               lastName = 'User',
                               email = uniqueName + '@testguest' + orgId + '.org',
                               Username = uniqueName + '@testguest' + orgId + '.org',
                               EmailEncodingKey = 'ISO-8859-1',
                               Alias = uniqueName.substring(18, 23),
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               CommunityNickname = 'nick2',
                               IsActive = True,
                               ProfileId = p.Id
                              );
        System.runAs(gu) {
            Test.startTest();
            String result = B2BCountrySelectorController.fetchLocales();
            Test.stopTest();
            
            //List<B2BCountrySelectorController.countryWrap> countryList = (List<B2BCountrySelectorController.countryWrap>) JSON.deserialize(result, List<B2BCountrySelectorController.countryWrap>.class);
            
            // Assert
            //System.assertNotEquals(0, countryList.size(), 'Expected non-zero countries for a normal user');
        }
    }
}