/**
 * @description       : Test Class
 * @author            : Mayank Srivastava
**/
@isTest
public class B2B_PaymentController_Test {
 	@TestSetup
    public static void testSetupData()
    {
       B2B_TestUtils.initialStorefrontSetup();
    }
    @isTest
    static void testSetPayment() {
        Map<String, Object> dataMap = new Map<String, Object>();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        B2B_testUtils.createCartWithCartItemsWithAcc('test cart',acc.Id);
        dataMap.put(B2BConstants.PAYMENT_TYPE,'Card');
        Webcart cart = [SELECT Id FROM WebCart LIMIT 1];
        dataMap.put(B2BConstants.CART_ID,cart.Id);
        dataMap.put(B2BConstants.CUSTOMER_TOKEN,'CT-91111');
        Test.startTest();
        Map<String, Object> result = B2B_PaymentController.setPayment(dataMap);
        Map<String, Object> resultNull = B2B_PaymentController.setPayment(null);
        Test.stopTest();

        // Add assertions here to validate the results
        System.assertNotEquals(null,result,'Wrong Output');
       
        
    }

    @isTest
    static void testGetCustomerToken() {
        Map<String, Object> dataMap = new Map<String, Object>();
        User u = [SELECT Id FROM User LIMIT 1];
        System.runAs(u)
        {
        Test.startTest();
        Map<String, Object> result = B2B_PaymentController.getCustomerToken(dataMap);
        Map<String, Object> resultNull = B2B_PaymentController.getCustomerToken(null);
        Test.stopTest();

        // Add assertions here to validate the results
        System.assertEquals(true,(Boolean)result.get(B2BConstants.IS_SUCCESS),'Wrong Output');
        System.assertEquals(false,(Boolean)resultNull.get(B2BConstants.IS_SUCCESS),'Wrong Output');
        }
    }

    @isTest
    static void testGetDigitalWallets() {
        Map<String, Object> dataMap = new Map<String, Object>();
        User u = [SELECT Id FROM User LIMIT 1];
        System.runAs(u)
        {
        Test.startTest();
        Map<String, Object> result = B2B_PaymentController.getDigitalWallets(dataMap);
       	Map<String, Object> resultNull = B2B_PaymentController.getDigitalWallets(null);
        Test.stopTest();

        // Add assertions here to validate the results
        System.assertEquals(true, result.get(B2BConstants.IS_SUCCESS),'wrong output');
        }
    }

    @isTest
    static void testDeleteDigitalWallet() {
        Map<String, Object> dataMap = new Map<String, Object>();

        Test.startTest();
        Map<String, Object> result = B2B_PaymentController.deleteDigitalWallet(dataMap);
        Map<String, Object> resultNull = B2B_PaymentController.deleteDigitalWallet(null);
        Test.stopTest();

        // Add assertions here to validate the results
        System.assertEquals(true, result.get(B2BConstants.IS_SUCCESS),'wrong output');
        System.assertEquals(false,resultNull.get(B2BConstants.IS_SUCCESS),'wrong output');
        
    }
}