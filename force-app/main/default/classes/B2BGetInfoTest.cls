@isTest
public class B2BGetInfoTest {
    @isTest
    static void getProductTest() {
        B2b_TestUtils.createWebStore(true);
        String networkId = Network.getNetworkId();
        Map<String,String> initResponse = B2b_TestUtils.initialStorefrontSetup();
        String proId = (String)initResponse.get('productId');
        String accId = (String)initResponse.get('accountId');
        String storeId = (String)initResponse.get('ZimVie');
        Community community = [ SELECT Id FROM Community  LIMIT 1];
       // WebStore store = [SELECT Id, Name FROM WebStore WHERE Name = 'ZimVie' LIMIT 1];
        ConnectApi.ProductDetail prodDetail = B2BGetInfo.getProduct(community.Id,proId,accId);
        System.assertNotEquals(null, prodDetail);
        
        
    }

	@isTest
    static void getInfoTest(){
         B2b_TestUtils.createWebStore(true);
        String itemId = null;
        //String cartItemId = [SELECT Id, Name FROM CartItem WHERE Name = 'Test CartItem' LIMIT 1].Id;
        WebStore ws = [SELECT Id, Name FROM WebStore WHERE Name = 'ZimVie'];
        Map<String,String> initResponse = B2b_TestUtils.initialStorefrontSetup();
        String wsId = ws.Id; //(String)initResponse.get('webStoreId');
        String proId = (String)initResponse.get('productId');
        String accId = (String)initResponse.get('accountId');
        Boolean isGuest = false;
        String quantity = '2';
        String wishList = 'My Wishlist';
        
        Network community = [SELECT Id, Name FROM Network WHERE Status = 'Live' LIMIT 1];
        

        // Link the Network (Community) with the Webstore
        WebStoreNetwork wsNet = new WebStoreNetwork();
        wsNet.NetworkId = community.Id;
        wsNet.WebStoreId = wsId;
        insert wsNet;
        
        String COMM_ID = community.Id;
        
        B2BGetInfo.getProduct(COMM_ID, proId, accId);
        B2BGetInfo.getCartSummary(COMM_ID, accId);
        B2BGetInfo.checkProductIsInStock(proId);
        B2BGetInfo.addToCart(COMM_ID, proId, quantity, accId);
        B2BGetInfo.createAndAddToList(COMM_ID, proId, wishList, accId);
        B2BGetInfo.getProductPrice(COMM_ID, proId, accId);
        //B2BGetInfo.fetchProductsFromApex(null, COMM_ID);
        
        B2BGetInfo.createWishlist(wishList, accId, wsId);
        List<Wishlist> wishListLst= B2BGetInfo.fetchWishlists(accId);
        String wishlistId = wishListLst[0].Id;
        B2BGetInfo.deleteWishlist(wishlistId);
        B2BGetInfo.addItemToWishlist(wishlistId, accId, wsId, proId);
        B2BGetInfo.fetchWishlistSummary(10, null, accId, wishlistId);
        B2BGetInfo.removeItem(accId, wishlistId, itemId);
        B2BGetInfo.updateWishlist(wishlistId,'My Wishlist new');
        B2BGetInfo.addWishlistToCart(wishlistId, accId);
       // B2BGetInfo.getCartItemsByCartId(cartId);
       // B2BGetInfo.updateCartItems(COMM_ID, accId, cartItemId, '20');
        
        // Webcart
        WebCart wc = createWebCart();
        //B2BGetInfo.getActiveCart(); 
    }
    
    private static WebCart createWebCart(){
        WebCart wc = B2B_TestUtils.createCartWithCartItems('Test Cart 01');
        return wc;
    }
}