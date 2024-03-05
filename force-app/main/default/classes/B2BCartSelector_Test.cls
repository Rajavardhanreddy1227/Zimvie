@isTest
private class B2BCartSelector_Test {
    @TestSetup
    public static void testSetupData()
    {
        B2B_TestUtils.initialStorefrontSetup();
        Account ac = B2B_TestUtils.createAccount(true);
        B2B_TestUtils.createCartWithCartItemsWithAcc('ZimVieTest',ac.Id);

    }
    @isTest
    static void testQueryCartDetails() {
        // Create test data
        WebCart testCart = [SELECT Id FROM Webcart LIMIT 1];

        Test.startTest();
        WebCart result = B2BCartSelector.queryCartDetails(new List<String>{testCart.Id});
        Test.stopTest();

        System.assertEquals(testCart.Id, result.Id);
    }

    @isTest
    static void testQueryCartTaxDetails() {
        // Create test data
        WebCart testCart = [SELECT Id FROM Webcart LIMIT 1];

        

        Test.startTest();
        List<CartTax> result = B2BCartSelector.queryCartTaxDetails(testCart.Id);
        Test.stopTest();

        System.assertEquals(0, result.size(),'wrong output');
    }

    @isTest
    static void testGetQueryFieldString() {
        Set<String> fields = B2BCartSelector.getDefaultFields();
        String expectedResult = String.join(new List<String>(fields), ',');

        String result = B2BCartSelector.getQueryFieldString();

        System.assertEquals(expectedResult, result);
    }

    @isTest
    static void testGetQueryCartTaxString() {
        Set<String> fields = B2BCartSelector.getCartTaxFields();
        String expectedResult = String.join(new List<String>(fields), ',');

        String result = B2BCartSelector.getQueryCartTaxString();

        System.assertEquals(expectedResult, result);
    }
}