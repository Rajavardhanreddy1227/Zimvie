@isTest
public class B2BTaxService_Test {
    @testSetup static void setup() {
        Account account = new Account(Name='TestAccount');
        insert account;
        WebStore webStore = new WebStore(Name='TestWebStore');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;
        
        CartItem cartItem = new CartItem(
            CartId=cart.Id, 
            Sku='SKU_Test1', 
            Quantity=3.0, 
            Type='Product', 
            Name='TestProduct', 
            CartDeliveryGroupId=cartDeliveryGroup.Id
        );
        insert cartItem;
    }
    @isTest
    static void tax(){
        WebCart cart =[Select id from WebCart where Name = 'Cart'];
        test.startTest();
       // B2BTaxService.initTax(cart.Id);
        test.stopTest();
    }    

}