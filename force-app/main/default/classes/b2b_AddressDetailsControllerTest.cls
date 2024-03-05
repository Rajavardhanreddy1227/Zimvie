@isTest
public class b2b_AddressDetailsControllerTest {

     @isTest
    static void getCartByItem() {
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1');
        insert cartDeliveryGroup;
        CartItem cartItem = new CartItem(CartId=cart.Id, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem;
        Set<String> cartId = new Set<String>{cart.Id};
        List<String> cartFields = new List<String>{'Name','WebStoreId','AccountId'};
        List<String> cartItemFields = new List<String>{'CartId','Type','Name'};
         b2b_AddressDetailsController.getCartWithItemsByIds(cartId, cartFields, cartItemFields);
         }
     @isTest
    static void getCartByTest() {
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1');
        insert cartDeliveryGroup;
        CartItem cartItem = new CartItem(CartId=cart.Id, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem;
         Set<String> cartFields = new Set<String>{'Name','WebStoreId','AccountId'};
             try{
          b2b_AddressDetailsController addDetail = new b2b_AddressDetailsController();
          b2b_AddressDetailsController.getById(cart.Id, cartFields);
          b2b_AddressDetailsController.getAddressesDetails(cart.id);
             }catch(Exception e){
                 
             }
         }
}