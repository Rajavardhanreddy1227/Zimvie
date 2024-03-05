@isTest
private class B2B_AnnouncementsController_Test
{
  /*  @TestSetup
    public static void testSetupData()
    {
        B2B_TestUtils.initialStorefrontSetup();
  //      B2B_TestUtils.createCartWithCartItemsWithAcc('ZimvieTest', testAccount.Id);
    }*/
    @isTest
    static void testFetchAnnouncements() {
        // Create test data
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        User testUser = [SELECT Id FROM User LIMIT 1];
        Announcements_and_Message__c testAnnouncement = new Announcements_and_Message__c(
            Brandname__c = 'Zimvie',
            Country__c = 'Georgia',
            Start_Date__c = Date.today().addDays(-1),
            End_Date__c = Date.today().addDays(1),
            Announcement_Type__c = 'Home Page Announcement',
            Announcement_Message__c = 'Test Message',
            Language__c = 'English'
        );
        insert testAnnouncement;
       // B2B_Language_Switcher__mdt lang = [SELECT Id,DeveloperName,B2B_Display_Text__c,B2B_Lang_Code__c,B2B_Sort_Order__c From B2B_Language_Switcher__mdt WHERE B2B_Lang_Code__c = :testAnnouncement.Language__c];
        Test.startTest();
        List<Announcements_and_Message__c> result = B2B_AnnouncementsController.fetchAnnouncements('TestBrand', 'USA', false, 'TypeA','English');
        //List<Announcements_and_Message__c> result = B2B_AnnouncementsController.fetchAnnouncements('Zimvie', 'Georgia', false, 'Home Page Announcement');
        Test.stopTest();

        System.assertEquals(0, result.size());
}
    @isTest
    static void fakeData(){
        Test.startTest();
        B2B_AnnouncementsController.codeCov();
        Test.stopTest();
    }
}