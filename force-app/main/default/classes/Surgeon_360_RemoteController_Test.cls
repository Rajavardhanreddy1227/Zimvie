@isTest
private class Surgeon_360_RemoteController_Test {
    
    @testSetup static void setup() {
        
        Trigger_Settings__c cs = new Trigger_Settings__c();
        cs.Name = 'AddUsersToPSQueues Trigger';
        cs.Active__c = true;
        insert cs; 
     }

    private static void createAccounts() {
        List<Account> accs = new List<Account>();
        for (Integer i = 0; i < 100; i++) {
            accs.add(Surgeon_360_TestHelper.createAccount(String.valueOf(i)));
        }
        insert accs;
    }

    private static Map<String, String> requestMap() {
        Map<String, String> request = new Map<String, String>();
        request.put('firstName', 'TestFirst');
        request.put('lastName', 'TestLast');
        return request;
    }

    @isTest static void getSearchResult() {
        createAccounts();

        Test.startTest();
        Surgeon_360_ResponseWrapper result = Surgeon_360_RemoteController.getSearchResult(requestMap(), 0);
        Test.stopTest();

        System.assertEquals(true, result.success);
        System.assertEquals(Surgeon_360_RemoteController.CORRECT_MESSAGE, result.message);
        System.assertNotEquals(null, result.data);
    }

    @isTest static void getProfileSummaryWithOutRating() {
        System.runAs(Surgeon_360_TestHelper.createUser()) {
            Surgeon_360_TestHelper.setup(true);
            Test.startTest();
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Surgeon_360_ResponseWrapper result = Surgeon_360_RemoteController.getProfileSummary(acc.Id);
            Test.stopTest();
            Map<String, Object> dataMap = (Map<String, Object>)(result.data);
            System.assertEquals(true, result.success);
            System.assertEquals(Surgeon_360_RemoteController.CORRECT_MESSAGE, result.message);
            System.assertNotEquals(null, result.data);
            System.assertEquals(false, dataMap.keySet().contains('rating'));
        }
    }

    @isTest static void getProfileSummaryWithRatingWithError() {
        System.runAs(Surgeon_360_TestHelper.createUser()) {
            Surgeon_360_TestHelper.setup(false);
            Test.startTest();
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Surgeon_360_ResponseWrapper result = Surgeon_360_RemoteController.getProfileSummary(acc.Id);
            Test.stopTest();
            System.assertEquals(false, result.success);
            System.assertEquals(Surgeon_360_RemoteController.ERROR_MESSAGE, result.message);
            System.assertEquals(null, result.data);
        }
    }

    @isTest static void getProfileSummaryWithRatingBronze() {
        System.runAs(Surgeon_360_TestHelper.createUser()) {
            Surgeon_360_TestHelper.createSurgeonSettings(0);
            Surgeon_360_TestHelper.setupRatingSettings();
            Surgeon_360_TestHelper.setup(false);

            Test.startTest();
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Surgeon_360_ResponseWrapper result = Surgeon_360_RemoteController.getProfileSummary(acc.Id);
            Test.stopTest();
            Map<String, Object> dataMap = (Map<String, Object>)(result.data);
            Surgeon_360_ResponseWrapper.RatingWrapper rating = (Surgeon_360_ResponseWrapper.RatingWrapper)(dataMap.get('rating'));

            System.assertEquals('Bronze', rating.label);
            System.assertEquals(true, result.success);
            System.assertEquals(Surgeon_360_RemoteController.CORRECT_MESSAGE, result.message);
            System.assertNotEquals(null, result.data);
        }
    }

    @isTest static void getProfileSummaryWithRatingSilver() {
        System.runAs(Surgeon_360_TestHelper.createUser()) {
            Surgeon_360_TestHelper.createSurgeonSettings(7);
            Surgeon_360_TestHelper.setupRatingSettings();
            Surgeon_360_TestHelper.setup(false);

            Test.startTest();
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Surgeon_360_ResponseWrapper result = Surgeon_360_RemoteController.getProfileSummary(acc.Id);
            Test.stopTest();
            Map<String, Object> dataMap = (Map<String, Object>)(result.data);
            Surgeon_360_ResponseWrapper.RatingWrapper rating = (Surgeon_360_ResponseWrapper.RatingWrapper)(dataMap.get('rating'));

            System.assertEquals('Silver', rating.label);
            System.assertEquals(true, result.success);
            System.assertEquals(Surgeon_360_RemoteController.CORRECT_MESSAGE, result.message);
            System.assertNotEquals(null, result.data);
        }
    }
}