@isTest
public class B2BOrderManagementController_Test {
    @TestSetup
    public static void testSetupData()
    {
        B2B_TestUtils.initialStorefrontSetup();
        Account ac = B2B_TestUtils.createAccount(true);
        B2B_TestUtils.createCartWithCartItemsWithAcc('ZimVieTest',ac.Id);
    }
    @isTest
    static void testValidateandSaveReturnOrder() {
        List<b2BOrderManagementController.OrderItemWrapper> listOfOrders = new List<b2BOrderManagementController.OrderItemWrapper>();
        // Create OrderItemWrapper objects and add them to listOfOrders
        
        String jsonOfListOfOrders = JSON.serialize(listOfOrders);

        Test.startTest();
        String result = b2BOrderManagementController.validateandSaveReturnOrder(jsonOfListOfOrders);
        String result1 = b2BOrderManagementController.validateandSaveReturnOrder(null);
        Test.stopTest();

        System.assertNotEquals(null,result,'Wrong Output');
        System.assertEquals(null,result1,'Expected Null');
    }
    
    
    //Not Working
    @isTest
    static void testErrorWrapperProperties() {
        // Create an instance of the errorWrapper class
        b2BOrderManagementController.errorWrapper wrapper = new b2BOrderManagementController.errorWrapper();

        // Test orderIdErrorSet property
        wrapper.orderIdErrorSet = new Set<String>{'Order1', 'Order2'};
        System.assertEquals(2, wrapper.orderIdErrorSet.size(), 'orderIdErrorSet should contain 2 items');

        // Test orderIdDateErrorSet property
        wrapper.orderIdDateErrorSet = new Set<String>{'OrderDate1', 'OrderDate2'};
        System.assertEquals(2, wrapper.orderIdDateErrorSet.size(), 'orderIdDateErrorSet should contain 2 items');

        // Test qtyErrorSet property
        wrapper.qtyErrorSet = new Set<String>{'Qty1', 'Qty2'};
        System.assertEquals(2, wrapper.qtyErrorSet.size(), 'qtyErrorSet should contain 2 items');

        // Test expDateErrorSet property
        wrapper.expDateErrorSet = new Set<String>{'ExpDate1', 'ExpDate2'};
        System.assertEquals(2, wrapper.expDateErrorSet.size(), 'expDateErrorSet should contain 2 items');

        // Test lotNoErrorSet property
        wrapper.lotNoErrorSet = new Set<String>{'LotNo1', 'LotNo2'};
        System.assertEquals(2, wrapper.lotNoErrorSet.size(), 'lotNoErrorSet should contain 2 items');
    }
    
    //Not Working
     @isTest
    static void testOrderItemWrapperProperties() {
        // Create an instance of the OrderItemWrapper class
        b2BOrderManagementController.OrderItemWrapper wrapper = new b2BOrderManagementController.OrderItemWrapper();

        // Set values for the properties
        wrapper.item = 'Item1';
        wrapper.quantity = '10';
        wrapper.lot = 'Lot123';
        wrapper.expiryDate = '2023-12-31';
        wrapper.order = 'Order123';
        wrapper.invoice = 'Invoice123';
        wrapper.resell = 'true';
        wrapper.comments = 'Test comments';
        wrapper.reorderItem = 'ReorderItem1';
        wrapper.reorderQuantity = '5';

        // Test the values of the properties using assertions
        System.assertEquals('Item1', wrapper.item);
        System.assertEquals('10', wrapper.quantity);
        System.assertEquals('Lot123', wrapper.lot);
        System.assertEquals('2023-12-31', wrapper.expiryDate);
        System.assertEquals('Order123', wrapper.order);
        System.assertEquals('Invoice123', wrapper.invoice);
        System.assertEquals('true', wrapper.resell);
        System.assertEquals('Test comments', wrapper.comments);
        System.assertEquals('ReorderItem1', wrapper.reorderItem);
        System.assertEquals('5', wrapper.reorderQuantity);
    }
    
    
	//Can't cover the catch.
    @isTest
    static void testGetUserDetails() {
        User testUser = [SELECT Id FROM User LIMIT 1];

        Test.startTest();
        String userDetails = b2BOrderManagementController.getUserDetails(testUser.Id);
        String userDetails1 = b2BOrderManagementController.getUserDetails('##');
        Test.stopTest();

        System.assertNotEquals(null,userDetails,'Wrong Output');
        //System.assertEquals(null,userDetails1,'Expected Null');
    }

    // Similar methods for other methods in the controller

    // Example for testValidateandSaveRMADetails
    @isTest
    static void testValidateandSaveRMADetails() {
        
        // Set values in mapParams to simulate input data
        
       /* Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact =[SELECT Id FROM Contact LIMIT 1];
        User testUser = [SELECT Id FROM User LIMIT 1];
        Webcart testcart = [SELECT Id FROM Webcart LIMIT 1];
        Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];
        
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('RMAType','Return');
        mapParams.put('accId',testAccount.Id);
        mapParams.put('contactId',testContact.Id);
        mapParams.put('userId',testUser.Id);
        mapParams.put('cartId',testcart.Id);
        List<Map<Object,Object>> filterList = new List<Map<Object,Object>>();
        Map<Object,Object> str = new Map<Object,Object>();
        str.put('Item',testProduct.Id);
        str.put('Quantity',34);
        str.put('Return', 'Unknown');
        str.put('Invoice','Invoice');
        str.put('Lot','lot');
        str.put('Resell',true);
        str.put('Expirydate','2023-17-08');
        str.put('Comments','comments');
        str.put('OrderId','OrderId');
        str.put('ReturnReason','Not Satisfied');
        str.put('ReorderItem',testProduct.Id);
        str.put('ReorderQuantity',12);
        str.put('ReturnReasonCourtsey','Dropped during surgery');
        str.put('PatientId','PatientId');
        str.put('EventDate','2021-17-08');
        filterList.add(str);
        mapParams.put('filterList',filterList);
        
        Map<String, Object> mapParams1 = new Map<String, Object>();
        mapParams1.put('accId',testAccount.Id);
        mapParams1.put('contactId',testContact.Id);
        mapParams1.put('userId',testUser.Id);
        mapParams1.put('RMAType','Exchange');
        
        
        Map<String, Object> mapParams2 = new Map<String, Object>();
        mapParams2.put('RMAType','Exchange');
        mapParams2.put('accId',testAccount.Id);
        mapParams2.put('contactId',testContact.Id);
        mapParams2.put('userId',testUser.Id);
        mapParams2.put('cartId',testcart.Id);
        List<Map<Object,Object>> filterList1 = new List<Map<Object,Object>>();
        Map<Object,Object> str1 = new Map<Object,Object>();
        str1.put('Item',testProduct.Id);
        str1.put('Quantity',34);
        str1.put('Return', 'Unknown');
        //str1.put('Invoice','Invoice');
        str1.put('Lot','lot');
        str1.put('Resell',true);
        str1.put('Expirydate','2023-17-08');
        //str1.put('Comments','comments');
        str1.put('OrderId','OrderId');
        str1.put('ReturnReason','Not Satisfied');
        str1.put('ReorderItem',testProduct.Id);
        str1.put('ReorderQuantity',12);
        str1.put('ReturnReasonCourtsey','Dropped during surgery');
        str1.put('PatientId','PatientId');
        str1.put('EventDate','2021-17-08');
        filterList1.add(str1);
        mapParams2.put('filterList',filterList1);
        
        
        Map<String, Object> mapParams3 = new Map<String, Object>();
        mapParams3.put('RMAType','Exchange');
        mapParams3.put('accId',testAccount.Id);
        mapParams3.put('contactId',testContact.Id);
        mapParams3.put('userId',testUser.Id);
        mapParams3.put('cartId',testcart.Id);
        List<Map<Object,Object>> filterList2 = new List<Map<Object,Object>>();
        Map<Object,Object> str2 = new Map<Object,Object>();
        str2.put('Item',testProduct.Id);
        str2.put('Quantity',34);
        str2.put('Return', 'Unknown');
        //str1.put('Invoice','Invoice');
        str2.put('Lot','lot');
        str2.put('Resell',true);
        str2.put('Expirydate','2023-17-08');
        //str1.put('Comments','comments');
        str2.put('OrderId','OrderId');
        str2.put('ReturnReason','Not Satisfied');
        //str2.put('ReorderItem',testProduct.Id);
        str2.put('ReorderQuantity',12);
        str2.put('ReturnReasonCourtsey','Dropped during surgery');
        str2.put('PatientId','PatientId');
        str2.put('EventDate','2021-17-08');
        filterList2.add(str2);
        mapParams3.put('filterList',filterList2);
        
        Map<String, Object> mapParams4 = new Map<String, Object>();
        mapParams4.put('RMAType','Courtesy');
        mapParams4.put('accId',testAccount.Id);
        mapParams4.put('contactId',testContact.Id);
        mapParams4.put('userId',testUser.Id);
        mapParams4.put('cartId',testcart.Id);
        List<Map<Object,Object>> filterList3 = new List<Map<Object,Object>>();
        Map<Object,Object> str3 = new Map<Object,Object>();
        str3.put('Item',testProduct.Id);
        str3.put('Quantity',34);
        str3.put('Return', 'Unknown');
        //str1.put('Invoice','Invoice');
        str3.put('Lot','lot');
        str3.put('Resell',true);
        str3.put('Expirydate','2023-17-08');
        //str1.put('Comments','comments');
        str3.put('OrderId','OrderId');
        str3.put('ReturnReason','Not Satisfied');
        str3.put('ReorderItem',testProduct.Id);
        str3.put('ReorderQuantity',12);
        str3.put('ReturnReasonCourtsey','Dropped during surgery');
        str3.put('PatientId','PatientId');
        str3.put('EventDate','2021-17-08');
        filterList3.add(str3);
        mapParams4.put('filterList',filterList3);
        
        Map<String, Object> mapParams5 = new Map<String, Object>();
        mapParams5.put('RMAType','Courtesy');
        mapParams5.put('accId',testAccount.Id);
        mapParams5.put('contactId',testContact.Id);
        mapParams5.put('userId',testUser.Id);
        mapParams5.put('cartId',testcart.Id);
        List<Map<Object,Object>> filterList4 = new List<Map<Object,Object>>();
        Map<Object,Object> str4 = new Map<Object,Object>();
        str4.put('Item',testProduct.Id);
        str4.put('Quantity',34);
        str4.put('Return', 'Unknown');
        //str1.put('Invoice','Invoice');
        str4.put('Lot','lot');
        str4.put('Resell',true);
        str4.put('Expirydate','2023-17-08');
        //str1.put('Comments','comments');
        str4.put('OrderId','OrderId');
        str4.put('ReturnReason','Not Satisfied');
        //str4.put('ReorderItem',testProduct.Id);
        str4.put('ReorderQuantity',12);
        str4.put('ReturnReasonCourtsey','Dropped during surgery');
        str4.put('PatientId','PatientId');
        str4.put('EventDate','2021-17-08');
        filterList4.add(str4);
        mapParams5.put('filterList',filterList4);

        Test.startTest();
        Map<String, Object> bestCase = b2BOrderManagementController.validateandSaveRMADetails(mapParams);
        Map<String, Object> resultMap1 = b2BOrderManagementController.validateandSaveRMADetails(mapParams1);
        Map<String, Object> resultMap2 = b2BOrderManagementController.validateandSaveRMADetails(mapParams2);
        Map<String, Object> resultMap3 = b2BOrderManagementController.validateandSaveRMADetails(mapParams3);
        Map<String, Object> resultMap4 = b2BOrderManagementController.validateandSaveRMADetails(mapParams4);
        Map<String, Object> resultMap5 = b2BOrderManagementController.validateandSaveRMADetails(mapParams5);
        Map<String, Object> resultMap6 = b2BOrderManagementController.validateandSaveRMADetails(null);
        Test.stopTest();*/

        // Assert your expectations based on the resultMap
        // ...
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
Contact testContact = [SELECT Id FROM Contact LIMIT 1];
User testUser = [SELECT Id FROM User LIMIT 1];
Webcart testCart = [SELECT Id FROM Webcart LIMIT 1];
Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];

// Case 1: Return RMA with Return Reason
Map<String, Object> mapParams1 = new Map<String, Object>();
mapParams1.put('RMAType', 'Return');
mapParams1.put('accId', testAccount.Id);
mapParams1.put('contactId', testContact.Id);
mapParams1.put('userId', testUser.Id);
mapParams1.put('cartId', testCart.Id);

List<Map<Object, Object>> filterList1 = new List<Map<Object, Object>>();
Map<Object, Object> case1 = new Map<Object, Object>();
case1.put('Item', testProduct.Id);
case1.put('Quantity', 10);
case1.put('Return', 'Defective');
case1.put('Invoice', 'Invoice-123');
case1.put('Lot', 'Lot-123');
case1.put('Resell', false);
case1.put('Expirydate', '2023-08-30');
case1.put('Comments', 'Defective item');
filterList1.add(case1);
mapParams1.put('filterList', filterList1);
// Call the method validateandSaveRMADetails with mapParams1

// Case 2: Exchange RMA
Map<String, Object> mapParams2 = new Map<String, Object>();
mapParams2.put('RMAType', 'Exchange');
mapParams2.put('accId', testAccount.Id);
mapParams2.put('contactId', testContact.Id);
mapParams2.put('userId', testUser.Id);
mapParams2.put('cartId', testCart.Id);

List<Map<Object, Object>> filterList2 = new List<Map<Object, Object>>();
Map<Object, Object> case2 = new Map<Object, Object>();
case2.put('Item', testProduct.Id);
case2.put('Quantity', 5);
case2.put('Return', 'Unknown');
case2.put('ReorderItem', testProduct.Id);
case2.put('ReorderQuantity', 3);
        case2.put('ReturnReason','Not Satisfied');
        case2.put('ReorderItem',testProduct.Id);
        case2.put('ReorderQuantity',12);
filterList2.add(case2);
mapParams2.put('filterList', filterList2);
// Call the method validateandSaveRMADetails with mapParams2

// Case 3: Courtesy RMA with Return Reason
Map<String, Object> mapParams3 = new Map<String, Object>();
mapParams3.put('RMAType', 'Courtesy');
mapParams3.put('accId', testAccount.Id);
mapParams3.put('contactId', testContact.Id);
mapParams3.put('userId', testUser.Id);
mapParams3.put('cartId', testCart.Id);

List<Map<Object, Object>> filterList3 = new List<Map<Object, Object>>();
Map<Object, Object> case3 = new Map<Object, Object>();
case3.put('Item', testProduct.Id);
case3.put('Quantity', 2);
case3.put('Return', 'Dropped');
case3.put('ReorderItem', testProduct.Id);
case3.put('ReorderQuantity', 1);
case3.put('ReturnReasonCourtsey', 'Dropped during handling');
case3.put('PatientId', 'Patient-001');
case3.put('EventDate', '2023-08-30');
filterList3.add(case3);
mapParams3.put('filterList', filterList3);
// Call the method validateandSaveRMADetails with mapParams3

        Test.startTest();
        Map<String, Object> resultMap1 = b2BOrderManagementController.validateandSaveRMADetails(mapParams1);
        Map<String, Object> resultMap2 = b2BOrderManagementController.validateandSaveRMADetails(mapParams2);
        Map<String, Object> resultMap3 = b2BOrderManagementController.validateandSaveRMADetails(mapParams3);
        Test.stopTest();

        
        
    }

    // Example for testGetShipmentDetails
    @isTest
    static void testGetShipmentDetails() {
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;

        // Create ShipmentItem records related to the testAccount

        Test.startTest();
        Map<String, String> shipmentDetails = b2BOrderManagementController.getShipmentDetails(testAccount.Id);
        Test.stopTest();

        // Assert your expectations based on the shipmentDetails
        // ...
    }

    // Example for testGetProductDetails
    @isTest
    static void testGetProductDetails() {
        // Create Product2 records

        Test.startTest();
        Map<String, String> productDetails = b2BOrderManagementController.getProductDetails('TestSKU');
        Test.stopTest();

        // Assert your expectations based on the productDetails
        // ...
    }

    // Example for testAddItemsToCartApex
    @isTest
    static void testAddItemsToCartApex() {
        // Create necessary data and set up the context

        Test.startTest();
        // Call the method to add items to the cart
        b2BOrderManagementController.addItemsToCartApex(new Map<String, String>{'ProductId1' => '5', 'ProductId2' => '10'});
        Test.stopTest();

        // Assert your expectations based on the cart items added
        // ...
    }
}