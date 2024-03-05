/**
 * @description       : 
 * @author            : asood@rafter.one
 * @group             : 
 * @last modified on  : 08-25-2023
 * @last modified by  : asood@rafter.one
**/
public with sharing class B2BConstants {

    public static final String STOREFRONT = 'Zimvie';

    public static final String IS_SUCCESS = 'isSuccess' ;
    public static final String MESSAGE = 'msg' ;
    public static final String IS_USER_EXIST = 'isUserExist';


    public static final String USER_ID = 'userId' ;
    public static final String ACCOUNT_ID = 'accountId' ;
    public static final String ADDRESS_TYPE_BILLING = 'Billing' ;
    public static final String ADDRESS_TYPE_SHIPPING = 'Shipping' ;
    public static final String CONTACT_ID = 'contactId' ;


    public static final String WEBSTORE_ID = 'webstoreId' ;
    public static final String COMMUNITY_ID = 'communityId';

    //Product Specific Constants
    public static final String SORT_RULES = 'sortRules' ;
    public static final String SEARCH_QUERY = 'searchQuery' ;
    public static final String PRODUCT_SEARCH_RESULTS = 'productSearchResult';
    public static final String PRODUCT_ID = 'productId';
    public static final String PRODUCT_SKU = 'sku';
    public static final String PRODUCT_IDS = 'productIds';
    public static final String PRICING_RESULT = 'pricingResult'; 


    public static final String PRODUCT_API_NAME = 'Product2' ;


    //Inventory Specific Constants
    public static final String IN_STOCK = 'inStock' ;
    public static final String STOCK_RESPONSE = 'stockResponse' ;
    public static final String PRODUCT_COUNT = 'productCount' ;


    //Registration Specific Constants
    public static final String FIRSTNAME = 'firstName' ;
    public static final String LASTNAME = 'lastName' ;
    public static final String EMAIL = 'email' ;
    public static final String USERNAME = 'userName' ;
    public static final String PHONE = 'phone' ;
    public static final String COMPANY = 'company' ;
    public static final String COMPANYWEB = 'companyWebcompanyWebsite' ;
    public static final String USERNAME_PREFIX = 'UsernamePrefix';
    public static final String LOGIN_URL = 'loginUrl' ;
    public static final String PASSWORD = 'password' ;
    public static final String COUNTRY_CODE = 'countryCode' ;
    public static final String STATE_CODE = 'stateCode' ;

    // B2B Product Relation Specific Constants
    public static final String RELATION_ID = 'relationId';
    public static final String CHILD_PRODUCT_IDS = 'childProductIds';
    public static final String RLTD_PRODUCT_LIMIT = 'rltdProductLimit';

    // B2B Product Section Specific Constants
    public static final String PRODUCT_SECTION_OBJ_LIST = 'productSectionObjList';
    public static final String PRODUCT_RECORD = 'product';

    public static final String PRODUCT_SECTION_LIST = 'productSectionList';
    public static final String SELECTED_PRODUCT_SECTION_ID = 'selectedProductSectionId';
    public static final String PRODUCT_SECTION_FILE = 'File';
    public static final String FILE_DOWNLOAD_URL = 'DownloadUrl';
    public static final String PRODUCT_DYNAMIC_SECTION = 'DynamicRichText'; 
    public static final String PRODUCT_SPECIFICATIONS_DYNAMIC_SECTION = 'ProductSpecifications';
    public static final String PRODUCT_API_FIELD_NAME = 'Product__c';
    public static final String PRODUCT_QUANTITY = 'productQuantity';
    public static final String PRODUCT_DETAILS = 'productDetails';
    public static final String PRODUCT_CODES_SET = 'productCodesSet';
    public static final String PRODUCT_ATTRIBUTES = 'productAttributes';


    // B2B Banner Carousel And Terms Specific Constants
    public static final String CONTENT_ID_STR = 'contentIdsStr';
    public static final String COLLECTION_OBJECT = 'collectionObject';
    public static final String LANGUAGE = 'en_US';
    public static final String CHANNEL_NAME = 'Rochester';
    public static final String BANNER_CONTENT_TYPE = 'B2B_Banner';
    public static final String TERMS_CONTENT_TYPE = 'B2B_Terms_And_Conditions';
    public static final String CAROUSEL_RESPONSES = 'carouselResponses';
    public static final String COLLECTION = 'collection';

    // CART RELATED Constants
    public static final String CART_ID = 'cartId';
    public static final String WEB_CART = 'WebCart';
    public static final String CART_DELIVERY_GROUP = 'CartDeliveryGroup';
    public static final String NO_CART_ID_FOUND_MESG = 'No Cart Id found';

    //Cart Item Specific Constants
    public static final String CART_ITEM_ID = 'cartItemId';
    public static final String CPN_NUMBER = 'cpnNumber';
    public static final String CART_ITEM_OBJECT = 'cartItemObj';
    public static final String GRAND_TOTAL_AMOUNT = 'grandTotalAmount';
    public static final String ALLOW_CHECKOUT = 'allowCheckout';
    public static final String CHECKOUT = 'Checkout';
    public static final String CART_TOTAL_VALIDATION = 'Cart Total Validation';
    public static final String CART_DELIVERY_GROUP_ID = 'cartDeliveryGroupId';

     // ACCOUNT RELATED Constants
     public static final String EFFECTIVE_ACCOUNT_ID = 'effectiveAccountId';
     public static final String ACCOUNT_CATEGORY_DISTRIBUTOR = 'Distributor'; 
     public static final String ACCOUNT_ID_FOR_CUSTOMER_PRICE = 'accIdforCustomerPrice'; 
     public static final String ACCOUNT_ID_LABEL = 'B2B_Account_Id'; 
     public static final String DISTRIBUTOR_ACCOUNT = 'distributorAccount'; 
     public static final String SAVE_TO_ADDRESS_BOOK = 'saveToAdressBook'; 

     //Tax Related Constants
     public static final String GEO_STATE_CODES = 'geoStateCodes'; 

     //Shipping Related Constants
     public static final String SHIPPPING_METHODS = 'shippingMethods'; 
     public static final String CARTITEM_TYPE_CHARGE = 'Charge'; 
     public static final String ORDER_DELIVERY_METHOD_ID = 'orderDeliveryMethodId'; 
     public static final String SELECTED_ORDER_DELIVERY_METHOD = 'selectedOrderDeliveryMethod'; 
     public static final String PRICE = 'price'; 
     public static final String CART_DELIVERY_METHOD_ID = 'cartDeliveryMethodId'; 
     public static final String FREE_SHIPPING_AMOUNT_LIMIT = 'B2B_Free_Shipping_Amount_Limit'; 
     public static final String FREE_ORDER_DELIVERY_METHOD_ID = 'Free_Order_Delivery_Method_Id'; 

    //Order Related Constants
    public static final String ORDER_PRODUCT = 'Order Product';
    public static final String ORDER_SUMMARY_NUMBER = 'orderSummaryNumber';
    public static final String ORDER_SUMMARY = 'orderSummary';
    public static final String ORDER_ITEM_SUMMARY_LIST = 'orderItemSummaryList';
    public static final String ORDER_DELIVERY_GROUPS = 'orderDeliveryGroups';
    public static final String ORDER_PAYMENT = 'orderPayment';

    // Payment Related Constant
    public static final String PAYMENT_TYPE = 'paymentType';
    public static final String CUSTOMER_TOKEN  = 'customerTokenId';
    public static final String BILLING_ADDRESS  = 'billingaddress';
    public static final String PAYMENT_INFO = 'paymentInfo';
    public static final String PAYMENT_TYPE_ACCOUNT = 'On Account';
    public static final String CARD_NUMBER  = 'cardNumber';
    public static final String PAYMENT_METHOD_ID  = 'paymentMethodId';
    public static final String DIGITAL_WALLET_ID  = 'digitalWalletId';
    public static final String CARD_CATEGORY  = 'CreditCard';
    public static final String CAPTURE_AMOUNT = 'Amount';
    public static final String CAPTURE_USER_NOT_FOUND = 'CUSTOMER-USER-NOT-FOUND';
    public static final String ACCOUNT_ID_STR = 'accountIdStr';

    public static final String TOKEN_ID  = 'token';
    public static final String KEY_ID  = 'keyId';
    public static final String JWK  = 'jwk';
    public static final String CURRENCY_ISO_CODE = 'currencyISOCode';
    public static final String CAPTURE_DATA_MISSING = 'REQUIRED-DETAIL-MISSING';
    public static final String COMMUNITY_TEMPLATE_NAME = 'B2B Commerce (LWR)';
    public static String POST = 'POST';
    public static final String PAYMENT_INSTRUMENT_ID  = 'paymentInstrumentId';
    public static final String DIGITAL_WALLETS  = 'digitalWallets';


    public static final String ORIGINAL_CART_ITEMS = 'originalCartItems';
    
}