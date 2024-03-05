@isTest
public class B2b_ShippingMethod_Test {
 @testSetup
    static void data(){
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1', DeliverToCountry = 'United States');
        insert cartDeliveryGroup;
        CartItem cartItem = new CartItem(CartId=cart.Id, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem;
    }
    @isTest
    static void findShipMethod(){
        List<Checkout_Shipping_method__c> shippingMethods = new List<Checkout_Shipping_method__c>();
        Checkout_Shipping_method__c shippingMethod1 = new Checkout_Shipping_method__c(
            Sku_Tax_Code__c = 'TaxCode1',
            Shipping_Charges__c = 10.0,
            Display_Name__c = 'Method 1',
            CurrencyISOCode = 'USD',
            Shipping_Carrier__c = 'Carrier 1',
            ShippingMethod_Country__c = 'United States' // Match the country you want to test
        );
        shippingMethods.add(shippingMethod1);
        insert shippingMethods;
        WebCart cart =[Select id,Name from WebCart where Name='Cart'];
        CartDeliveryGroup cartDelivery = [Select id, Name,DeliverToCountry,CartId from CartDeliveryGroup where Name='Default Delivery 1'];
        CartItem cartItem =[Select id, Name,type from CartItem where Name='TestProduct' and Type='Product'];
        String Country='United States';
		Test.startTest();
 		B2b_ShippingMethod.findShippingMethodByCountry(cartDelivery);
        B2b_ShippingMethod.ShippingOptionsAndRatesWrapper wrap = new B2b_ShippingMethod.ShippingOptionsAndRatesWrapper();
        wrap.getProvider();
        wrap.getCurrCode();
        wrap.getOtherCost();
        wrap.getRate();
        wrap.getServiceName();
        wrap.getName();
        B2b_ShippingMethod.ShippingOptionsAndRatesWrapper wrapper = new B2b_ShippingMethod.ShippingOptionsAndRatesWrapper('test','TestProvider',89.00,65.00,'testServicename','USD');
	    Test.stopTest();
    }
    @isTest
    static void getSelectDelivery(){
        WebCart cart = [Select id, name from Webcart where name='Cart'];
        Test.startTest();
        B2b_ShippingMethod.getSelectedDeliveryMethod(cart.id);
		Test.stopTest();
    }
}