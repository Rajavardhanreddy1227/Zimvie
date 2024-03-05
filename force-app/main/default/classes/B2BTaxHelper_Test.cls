@isTest
public class B2BTaxHelper_Test 
{
    @TestSetup
    public static void testSetupData()
    {
        B2B_TestUtils.initialStorefrontSetup();
        //Account ac = [SELECT Id FROM Account LIMIT 1];
        //B2B_TestUtils.createCartWithCartItemsWithAcc('zimvie cart', ac.Id);
        Webcart cart = [SELECT Id FROM Webcart LIMIT 1];
        CartItem item = [SELECT Id FROM CartItem LIMIT 1];
        CartTax ct = new CartTax();
        ct.Name ='TestTax';
        ct.TaxType = 'Actual';
        ct.TaxCalculationDate = Date.today()  +1;
        //ct.CartId = cart.Id;
        ct.Amount = 10;
        ct.CartItemId = item.Id;
        insert ct;
    }
    @isTest
    static void testDeleteExitingCartTaxes() {
        // Create test data: CartTax records related to a cart
       Webcart cart = [SELECT Id FROM Webcart LIMIT 1];
        
        // Call the method to be tested
        Test.startTest();
        B2BTaxHelper.deleteExitingCartTaxes(cart.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetTaxrate() {
        Webcart cart = [SELECT Id FROM Webcart LIMIT 1];        
        // Call the method to be tested
        Test.startTest();
        //Map<String, Object> result = B2BTaxHelper.getTaxrate(cart.Id);
        Test.stopTest();     
        // Add your assertions here
       //System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetTrackingGUID() {
        // Call the method to be tested
        Webcart cart = [SELECT Id FROM Webcart LIMIT 1];
        Test.startTest();
        String trackingGUID = B2BTaxHelper.getTrackingGUID(cart.Id);
        Test.stopTest();
       
        System.assertNotEquals(null, trackingGUID, 'trackingGUID should not be null');
      
    }
}