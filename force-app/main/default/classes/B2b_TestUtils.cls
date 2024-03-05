public class B2b_TestUtils {
		public static User defaultUser;
    	//public static User defaultGuestUser;
    	public static Account defaultAccount;
    	public static Contact defaultContact;
    
    	public static void initB2BData(){
       	  defaultAccount = createAccount(true);
          defaultContact = createContact(true);
       	  defaultUser = createCommunityUser(false);
      	  //defaultGuestUser = createGuestUser(true);
         }
    
    public static Map<String, String> initialStorefrontSetup() {
        
        Map<String, String> response = new Map<String, String>();
        
        ProductCatalog prodCatalog = new ProductCatalog();
        prodCatalog.Name = 'Test Catalog';
        insert prodCatalog;
        
        WebStore webStr = new WebStore();
        webStr.Name = 'ZimVie';
        webStr.PricingStrategy = 'LowestPrice';
        insert webStr;
        
        WebStoreCatalog web_Catalog = new WebStoreCatalog();
        web_Catalog.SalesStoreId = webStr.Id;
        web_Catalog.ProductCatalogId = prodCatalog.Id;
        insert web_Catalog;
        
        
        
        BuyerGroup buyGrp = new BuyerGroup();
        buyGrp.Name = 'ZimVie Buyer Group for testing';
        insert buyGrp;
        
        WebStoreBuyerGroup webStrBuyerGrp = new WebStoreBuyerGroup();
        webStrBuyerGrp.WebStoreId = webStr.Id;
        webStrBuyerGrp.BuyerGroupId = buyGrp.Id;
        insert webStrBuyerGrp;
        
        CommerceEntitlementPolicy commerceEntPolicy = new CommerceEntitlementPolicy(
            Name = 'Test Policy', Description = 'Test Description',
            CanViewProduct = true, CanViewPrice = true, IsActive = true
        );
        insert commerceEntPolicy;
        
        CommerceEntitlementBuyerGroup commerceEntBuyerGrp = new CommerceEntitlementBuyerGroup(
            PolicyId = commerceEntPolicy.Id,
            BuyerGroupId = buyGrp.Id
        );
        insert commerceEntBuyerGrp;
        
        RecordType rt1 = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Vendor' LIMIT 1];
        Account acc = new Account();
        acc.Name = 'Test Name';
        acc.Type = 'Customer';
        acc.Customer_Type__c = 'Pharmacy';
        acc.Account_eMail__c = 'lauren119@yopmail.com';
        acc.Email__c = 'neeta.galande@rafter.one';
        acc.RecordTypeId = rt1.Id;
        acc.ShippingCountry = 'United States';
        acc.ShippingState = 'Alabama';
        acc.ShippingPostalCode = '12345';
        insert acc;
        
        BuyerAccount buyrAcc = new BuyerAccount();
        buyrAcc.Name = acc.Name;
        buyrAcc.BuyerId = acc.Id;
        buyrAcc.IsActive = true;
        insert buyrAcc;
        WebCart cart = new WebCart(
                Name = 'Cart', 
                WebStoreId = webStr.Id, 
                AccountId = acc.Id, 
                CurrencyIsoCode = 'USD',
                PoNumber = '6794',
                BillingStreet = 'Street',
                BillingCity = 'New York',
                BillingState = 'New York',
                BillingPostalCode = '34562',
                BillingCountry = 'United States',
                BillingLatitude = 40.730610,
                BillingLongitude = -73.935242
                );
            insert cart;
/*        WebCart cart1 = new WebCart(
                Name = 'Test Carting', 
                WebStoreId = webStr.Id, 
                AccountId = acc.Id,         
                BillingStreet = 'Street123',
                BillingCity = 'California',
                BillingState = 'California',
                BillingPostalCode = '34662',
                BillingCountry = 'United States'
                
                );
            insert cart1;
*/
 /*       ProductCategory parent_category = new ProductCategory();
        parent_category.Name = 'ParentCategory';
        parent_category.Cat_ID__c = cart.Id;
        parent_category.CatalogId = prodCatalog.Id;
        parent_category.Description = 'Description';
        insert parent_category;
 */       
        ProductCategory prod_category = new ProductCategory();
        prod_category.Name = 'ProductCategory '+Integer.valueOf(Math.rint(Math.random() * 1000000));
        prod_category.IsNavigational = True;
        prod_category.Cat_ID__c = cart.Id;
        prod_category.SortOrder = 4;
        //prod_category.External_Key__c = 'Key';
        //prod_category.ParentCategoryId = parent_category.Id;
        prod_category.Description = 'Description';
        prod_category.CatalogId = prodCatalog.Id;
        insert prod_category;
        /*Operating_Unit__c op = new Operating_Unit__c();
        op.External_Key__c = 40;
        op.Name = 'operating';
        insert op;*/
        
        Pricebook2 newPricebook = new Pricebook2(
            Name = 'Test Book',
            IsActive = true
            //DefaultOperatingUnit__c  = op.id
        );
        insert newPricebook;
        
        Schema.Location loc = new Schema.Location();
        loc.Name = 'Test Location';
        loc.LocationType ='Site';
        
        insert loc;
        
        Product2 pro = new Product2(
            Name = 'Sort Material-450',
            IsActive = true,
            StockKeepingUnit = 'Sort'
        );
        insert pro;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
        System.assertEquals(true, standardPricebook.IsStandard);
        
        BuyerGroupPricebook buyerGrpPricebook = new BuyerGroupPricebook();
        buyerGrpPricebook.BuyerGroupId = buyGrp.Id;
        buyerGrpPricebook.Pricebook2Id = newPricebook.Id;
        buyerGrpPricebook.IsActive = true;
        insert buyerGrpPricebook;
        
        PricebookEntry pbe1 = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = pro.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        insert pbe1;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = newPricebook.Id,
            Product2Id = pro.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        insert pbe;
        
        CommerceEntitlementProduct commerceEntProduct = new CommerceEntitlementProduct(
            PolicyId = commerceEntPolicy.Id,
            ProductId = pro.Id
        );
        insert commerceEntProduct;
         OrderDeliveryMethod testOrderDeliveryMethod = new OrderDeliveryMethod(
                Name = 'Test Delivery Method', 
                ProductId = pro.id
            );
            insert testOrderDeliveryMethod;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
                CartId = cart.Id,
                Name = 'Default Delivery 1',
                DeliveryMethodId = testOrderDeliveryMethod.Id,
                CurrencyIsoCode = 'USD',
                DeliverToCountryCode = 'US',
                DesiredDeliveryDate = System.Now(),
                DeliverToName = 'TEst',
                ShippingInstructions = 'instr',
                DeliverToStreet = cart.BillingStreet,
                DeliverToCity = cart.BillingCity,
                DeliverToState = cart.BillingState,
                DeliverToPostalCode = cart.BillingPostalCode,
                DeliverToCountry = cart.BillingCountry,
                DeliverToLatitude = cart.BillingLatitude,
                DeliverToLongitude = cart.BillingLongitude
            );
            insert cartDeliveryGroup;
        CartItem cartItem1 = new CartItem(
                CartId = cart.Id,
                Type = 'Product',
                Sku = pro.StockKeepingUnit,
                Name = 'Cart Item 1',
                Quantity = 2.0,
                Product2Id = pro.Id,
                CartDeliveryGroupId = cartDeliveryGroup.Id,
                TotalPrice = 20.00,
                UnitAdjustedPrice = 20.00,
                AdjustmentAmount = 10.0, 
                ListPrice = 10.0, 
                SalesPrice = 10.0, 
                TotalLineAmount = 20.0
            );
            insert cartItem1;
        
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Zimmer_Standard_Contact' LIMIT 1];
        Contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = 'Contact';
        con.Email = 'testContact123@yopmail.com';
        con.RecordTypeId = rt.Id;
        //con.Active__c = True;
        //con.B2B_Contact_Name__c = 'Name';
        //con.eCom_Operating_Unit__c = op.Id;
        con.AccountId = acc.Id;
        //con.Bill_To_Contact__c = True;
        //con.Ship_To_Contact__c = True;
        //con.External_Key__c = 'extkey';
        //con.eCom_Price_Book__c = newPricebook.Id;
        //con.Oracle_Status__c = 'active';
        insert con;
        
        ContactPointAddress con_point_shipping = new ContactPointAddress();
        con_point_shipping.Name = 'Test Address Shipping';
        con_point_shipping.City = 'Goleta';
        con_point_shipping.PostalCode = '93117-3084';
        con_point_shipping.State = 'California';
        con_point_shipping.Country = 'United States';
        con_point_shipping.AddressType = 'Shipping';
        con_point_shipping.ActiveFromDate = Date.newInstance(2019, 12, 9);
        con_point_shipping.ActiveToDate = Date.newInstance(2021, 12, 9);
        con_point_shipping.ParentId = acc.Id;
        insert con_point_shipping;
        
        ContactPointAddress con_point_billing = new ContactPointAddress();
        con_point_billing.Name = 'Test Address Billing';
        con_point_billing.City = 'Goleta';
        con_point_billing.PostalCode = '93117-3084';
        con_point_billing.State = 'California';
        con_point_billing.Country = 'United States';
        con_point_billing.AddressType = 'Billing';
        con_point_billing.ActiveFromDate = Date.newInstance(2019, 12, 9);
        con_point_billing.ActiveToDate = Date.newInstance(2021, 12, 9);
		con_point_billing.ParentId = acc.Id;
        insert con_point_billing;
        
    /*    BuyerGroupMember buyGrpMem = new BuyerGroupMember();
        buyGrpMem.BuyerId = acc.Id;
        buyGrpMem.BuyerGroupId = buyGrp.Id;
        insert buyGrpMem;
   */    
        
       // Creating Community User
         
   /*     System.runAs(new User(Id = UserInfo.getUserId())) { 
        //UserRole userRole = [SELECT Id FROM UserRole WHERE Name = 'Agreement Specialist RC' LIMIT 1];    
        Profile zimvieProfile = [SELECT Id FROM Profile WHERE Name = 'ZimVie Profile' LIMIT 1];
        User admin = new User(
            Alias = 'admin',
            Email = 'admin@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = zimvieProfile.Id,
            //UserRoleId = userRole.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'admin' + DateTime.now().getTime() + '@example.com'
        );
        insert admin;
        }
        User admin1 = [SELECT Id, Name FROM User WHERE Email = 'admin@example.com' LIMIT 1]; 
        System.runAs(admin1) {
            UserRole userRole = [SELECT Id FROM UserRole WHERE Name = 'B2B-Test Account Customer User' LIMIT 1];
            Profile pf = [Select Id from profile where Name = 'B2B Lightning Community Plus Login' limit 1];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
            Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
            String uniqueName = orgId + dateString + RandomId;
            
            User uu = new User(firstname = 'ABC',
                               lastName = 'XYZ',
                               email = uniqueName + '@test' + orgId + '.org',
                               Username = uniqueName + '@test' + orgId + '.org',
                               EmailEncodingKey = 'ISO-8859-1',
                               Alias = uniqueName.substring(18, 23),
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               CommunityNickname = 'nick',
                               IsActive = True,
                               ProfileId = pf.Id,
                               UserRoleId = userRole.Id,
                               ContactId = con.Id,
                               PortalRole = 'Manager'
                               //CRM_PRM__c  = 'PRM',
                               //CRM_Type__c=''
                              );
            insert uu;
            response.put('userId', uu.Id);
        }
   */     
        response.put('productId', pro.Id);
        response.put('webStoreName', webStr.Name);
        response.put('webStoreId', webStr.Id);
        response.put('accountId', acc.Id);
        response.put('contactId', con.Id);
        response.put('productCategoryId',prod_category.Id);
        response.put('webCatalogId',web_Catalog.Id);
        response.put('accountId', acc.Id);
        response.put('pricebookEntryId', pbe1.Id);
        response.put('pricebookId', standardPricebook.Id);
        response.put('con_point_shippingId',con_point_shipping.Id);
        response.put('con_point_billingId', con_point_billing.Id);
        
        return response;
    }
    
    public static Account createAccount(Boolean doInsert){
        RecordType rt = [SELECT Id FROM RecordType 
                 WHERE SobjectType = 'Account' 
                 AND DeveloperName = 'Vendor' LIMIT 1];
        
        Account account  = new Account(Name='Test Account '+DateTime.now(),
                                       RecordTypeId = rt.Id,
                                       ShippingCountry = 'United States');
        if(doInsert){
            insert account;
        }
        defaultAccount = account;
        return account;
    }
    
    public static Contact createContact(Boolean doInsert){
        RecordType rt = [SELECT Id FROM RecordType 
                 WHERE SobjectType = 'Contact' 
                 AND DeveloperName = 'Zimmer_Standard_Contact' LIMIT 1];
        
        Contact contact  = new Contact(FirstName='Test',
                                       Lastname = 'Name',
                                       AccountId = defaultAccount.Id,
                                       RecordTypeId = rt.Id,
                                       Email = 'test.contact123@yopmail.com');
        if(doInsert){
            insert contact;
        }
        defaultContact = contact;
        return contact;
    } 
    
    public static User createCommunityUser(Boolean doInsert){
        UserRole userRole = [SELECT Id FROM UserRole WHERE Name = 'mdata Customer Person Account' LIMIT 1];
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name='B2B Lightning Community Plus Login' Limit 1];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
        String uniqueName = orgId + dateString + RandomId;
        User user  = new User(UserName = uniqueName + '@testcu' + orgId + '.org',
                              FirstName = defaultContact.FirstName,
                              LastName = defaultContact.LastName,
                              Alias = String.Valueof(defaultContact.FirstName).substring(0,1).toLowerCase() + String.Valueof(defaultContact.LastName).substring(0,4).toLowerCase(),
                              email = 'test.user123@yopmail.com',
                              ContactId = defaultContact.Id,
                              ProfileId = portalProfile.Id,
                              UserRoleId = userRole.Id,
                              EmailEncodingKey = 'UTF-8',
                              CommunityNickname = 'Test Community Nickname',
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        if(doInsert){
            insert user;
        }
        
        return user;
            
    }  
    public static User createGuestUser(){
        Profile p = [SELECT Id from Profile WHERE Name = 'Guest License User' LIMIT 1];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
            Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
            String uniqueName = orgId + dateString + RandomId;
            User gu = new User(firstname = 'Guest',
                               lastName = 'User',
                               email = uniqueName + '@testguest' + orgId + '.org',
                               Username = uniqueName + '@testguest' + orgId + '.org',
                               EmailEncodingKey = 'ISO-8859-1',
                               Alias = uniqueName.substring(18, 23),
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               CommunityNickname = 'nick2',
                               IsActive = True,
                               ProfileId = p.Id
                              );
        return gu;
    } 
   
    public static WebStore createWebStore(Boolean doInsert){
    	WebStore webStr = new WebStore();
        webStr.Name = 'ZimVie';
        webStr.PricingStrategy = 'LowestPrice';
        
        if(doInsert){
            insert webStr;
        }
        return webStr;
    }   
    // favorite address 
    public static Favorite_Address__c createFavAddress(String conId, String cpaId)
    {
          Favorite_Address__c fva = new Favorite_Address__c();
          fva.Contact__c = conId;
          fva.Contact_Point_Address__c = cpaId;
        //   fva.CurrencyIsoCode = 'USD - U.S. Dollar';
          insert fva;
          return fva;
    }    

    // default address
    public static void setDefaultAddress(String cpaId, String contactId)
    {
        Default_Address__c dfa = new Default_Address__c();
        dfa.Contact__c = contactId;
        dfa.Contact_Point_Address__c =cpaId;
        insert dfa;
    }  
    // Empty Cart
    public static WebCart createEmptyWebCart(Boolean doInsert){
			initB2BData();
        	WebStore ws = createWebStore(true);
        
            WebCart wc = new WebCart();
        	wc.name = 'Test Cart';
       		wc.AccountId = defaultAccount.Id;
        	wc.WebstoreId = ws.Id;
            wc.PoNumber = 'PO-012345';
            wc.Status = 'Active';
            wc.Type = 'Cart';
            wc.CurrencyIsoCode = 'USD';
                      
        if(doInsert){
            insert wc;
        }
        return wc;
     }
    
    // Cart with Cart Items
    public static WebCart createCartWithCartItems(String Name){
			initB2BData();
        	WebStore ws = createWebStore(true);
        
            WebCart wc = new WebCart();
        	wc.name = Name;
       		wc.AccountId = defaultAccount.Id;
        	wc.WebstoreId = ws.Id;
            wc.PoNumber = 'PO-123456';
            wc.Status = 'Active';
            wc.Type = 'Cart';
            wc.CurrencyIsoCode = 'USD';
            insert wc;
        
        	Product2 pro = createProduct('Test Product','SKU-001');
        	CartItem ci = createCartItem(wc.Id, pro.Id);
        
        return wc;
        	
     }


        // Cart with Cart Items
    public static WebCart createCartWithCartItemsWithAcc(String Name,String acId){
			// initB2BData();
        	WebStore ws = createWebStore(true);
        
            WebCart wc = new WebCart();
        	wc.name = Name;
       		wc.AccountId = acId;
        	wc.WebstoreId = ws.Id;
            wc.PoNumber = 'PO-123456';
            wc.Status = 'Active';
            wc.Type = 'Cart';
            wc.CurrencyIsoCode = 'USD';
            insert wc;
        
        	Product2 pro = createProduct('ZimVie Product','ZIM-001');
        	CartItem ci = createCartItemWithAcc(wc.Id, pro.Id,acId);
        
        return wc;
        	
     }
// digital wallets
public static void createWallet()
{    
        PaymentGateway pg = new PaymentGateway();
        pg.PaymentGatewayName = 'Test Payment Gateway';
        pg.Status ='Active';
        pg.PaymentGatewayProviderId ='0cJ8L000000KykdUAC';
        pg.MerchantCredentialId = '0XA8L0000008P6U';
        Insert pg;
        DigitalWallet wall  = new DigitalWallet();
        wall.B2B_Active__c = true;
        wall.CardHolderName__c= 'Zimvie Dev';
        wall.Card_Type__c = 'VISA';
        wall.CardLastFour__c = 1111;
        wall.ExpiryMonth__c =11;
        wall.ExpiryYear__c = 2023;
        wall.GatewayToken = 'TESTTOKEN';
        wall.PaymentGatewayId=pg.Id;
        wall.Status='Active';
        wall.ProcessingMode ='External';
        insert wall;
}
// RMA and RMA_Item
public static RMA__c createRMA(String acId,String conId,String userId)
     {
        RMA__c newrma = new RMA__c();
        newrma.AccountId__c = acId;
        newrma.Bill_to_Contact__c = conId;
        newrma.Raised_By__c = userId;
        newrma.RMA_TYPE__c = 'Return';
        newrma.Status__c = 'Submitted';

        insert newrma;

        return newrma;

     }
     public static RMA_Item__c createRMAItem(String acId,String conId,String userId)
     {
        RMA__c newrma = new RMA__c();
        newrma.AccountId__c = acId;
        newrma.Bill_to_Contact__c = conId;
        newrma.Raised_By__c = userId;
        newrma.RMA_TYPE__c = 'Return';

        RMA_Item__c rmaitem=new RMA_Item__c();

        return rmaitem;

     }

	// Product    
    public static Product2 createProduct(String name,String sku ){
       Product2 pro = new Product2(
            Name = name,
            IsActive = true,
            StockKeepingUnit = sku
        );
        insert pro;
        return pro;		
    }
    
    // Contract
    public static Contract createContract(String accId){
        Contract contrt = new Contract();
        contrt.AccountId = accId;
        contrt.CurrencyIsoCode = 'USD';
        contrt.StartDate = Date.Today();
        contrt.Status = 'Activated';
        contrt.ContractTerm = 240;
        insert contrt;
        return contrt;
    }
    
    // Order
    public static Order createOrder(String accId){
        Contract contrt = createContract(accId);
        Order od = new Order();
        od.AccountId = accId;
        od.ContractId = contrt.Id;
        od.EffectiveDate = Date.Today();
        od.Status = 'Activated';
        insert od;
        return od;
    }
    
    // Order Delivery Group
    public static OrderDeliveryGroup createOrderDeliveryGroup(String accId){
        Order od = createOrder(accId);
        OrderDeliveryGroup odg = new OrderDeliveryGroup();
        odg.OrderId = od.Id;
        odg.DeliverToName = 'Test Deliver Name';
        insert odg;
        return odg;
    }
    
    // Order Delivery Method
    public static OrderDeliveryMethod createOrderDeliveryMethod(String accId){
        
        OrderDeliveryMethod odm = new OrderDeliveryMethod();
        odm.Name = 'Test Order Delivery Method Name';
        insert odm;
        return odm;
    }
    
    // Cart Delivery Group
    public static CartDeliveryGroup createCartDeliveryGroup(String cartId, String accId){
        OrderDeliveryMethod odm = createOrderDeliveryMethod(accId);
        
        CartDeliveryGroup cdg = new CartDeliveryGroup();
        cdg.Name = 'Test Cart Delivery Group';
        cdg.CartId = cartId;
        cdg.DeliveryMethodId = odm.Id;
        cdg.DeliverToName = 'Test Deliver Name';
        insert cdg;
        return cdg;
    }
// cartItem New
    public static CartItem createCartItemWithAcc(String cartId, String productId, String acId){
       CartDeliveryGroup cdg = createCartDeliveryGroup(cartId, acId);
        
       CartItem ci = new CartItem();
        ci.Name = 'Test CartItem';
        ci.CartId = cartId;
        ci.CartDeliveryGroupId = cdg.Id;
        ci.CurrencyIsoCode = 'USD';
        ci.Product2Id = productId;
        ci.ListPrice = 80;
        ci.Quantity = 10;
        ci.SalesPrice = 100;
        ci.Sku = 'SKU-001';
        ci.Type = 'Product';
        ci.AdjustmentAmount = 200;
        ci.AdjustmentTaxAmount = 20;
        ci.TotalAdjustmentAmount = 200;
        ci.TotalPriceAfterAllAdjustments = 100;
        ci.TotalLineAmount = 100;
        ci.TotalListPrice = 90;
        ci.TotalPrice = 150;
        ci.UnitAdjustedPrice = 100;
        ci.NetUnitPrice = 30;
        ci.GrossUnitPrice = 40;
        
        insert ci;
        return ci;		
    }
    // Cart Item
    public static CartItem createCartItem(String cartId, String productId){
       CartDeliveryGroup cdg = createCartDeliveryGroup(cartId, defaultAccount.Id);
        
       CartItem ci = new CartItem();
        ci.Name = 'Test CartItem';
        ci.CartId = cartId;
        ci.CartDeliveryGroupId = cdg.Id;
        ci.CurrencyIsoCode = 'USD';
        ci.Product2Id = productId;
        ci.ListPrice = 80;
        ci.Quantity = 10;
        ci.SalesPrice = 100;
        ci.Sku = 'SKU-001';
        ci.Type = 'Product';
        ci.AdjustmentAmount = 200;
        ci.AdjustmentTaxAmount = 20;
        ci.TotalAdjustmentAmount = 200;
        ci.TotalPriceAfterAllAdjustments = 100;
        ci.TotalLineAmount = 100;
        ci.TotalListPrice = 90;
        ci.TotalPrice = 150;
        ci.UnitAdjustedPrice = 100;
        ci.NetUnitPrice = 30;
        ci.GrossUnitPrice = 40;
        
        insert ci;
        return ci;		
    }
    
    
    
    
    
     // Test productSearch
    public static ConnectApi.ProductSearchResults productSearch(){
        ConnectApi.ProductSearchResults psr = new ConnectApi.ProductSearchResults();
        // Search Category Data
        ConnectApi.SearchCategory categories = new ConnectApi.SearchCategory(); 
        ConnectApi.ProductCategoryData category = new ConnectApi.ProductCategoryData();
        category.description='Category description';
        category.id='Category Id';
        category.name='Category';
        categories.category = category;
        categories.productCount = 20;
 
        // Product Summary Page Data
        ConnectApi.ProductSummaryPage productsPage = new ConnectApi.ProductSummaryPage();
        productsPage.currencyIsoCode = 'USD';
        productsPage.pageSize = 1;
        productsPage.total = 1;
        psr.categories = categories;
        psr.correlationId ='correlationId';
        psr.locale = 'locale';
        psr.productsPage = productsPage;
        return psr;
    }
    
    // Test getSortRules
    public static ConnectApi.SortRulesCollection getSortRules(){
        ConnectApi.SortRulesCollection sortRulesP = new ConnectApi.SortRulesCollection();
        List<ConnectApi.SortRule> sortRules = new List<ConnectApi.SortRule>();
        for(ConnectApi.SortRule sortRule : sortRules){
            sortRule.label = 'PRODUCT SKU';
            sortRule.sortOrder = 1;
        }
        sortRulesP.sortRules = sortRules;
        return sortRulesP;
    }
    
    // Test getCartSummary
    public static ConnectApi.CartSummary getCartSummary(){
        ConnectApi.CartSummary  cartSum = new ConnectApi.CartSummary();
        cartSum.accountId = 'Account Id';
        cartSum.cartId = 'Cart Id';
        cartSum.currencyIsoCode = 'currencyIsoCode';
        cartSum.grandTotalAmount = 'grandTotalAmount';
        cartSum.name = 'Cart Name';
        cartSum.purchaseOrderNumber = 'purchaseOrderNumber';
        cartSum.totalProductCount = 'totalProductCount';
        return cartSum;
    }
    
    // Test addToCart
    public static ConnectApi.CartItem addToCart(){
        ConnectApi.CartItem  cartitem= new ConnectApi.CartItem();
        cartitem.listPrice = 'Test listPrice';
        cartitem.salesPrice = 'Test salesPrice';
        cartitem.totalAmount = 'Test totalAmount';
        cartitem.totalListPrice = 'Test totalListPrice';
        cartitem.totalPrice = 'Test totalPrice';
        return cartitem;
    }
    
    //Test getProductPrice
    public static ConnectApi.ProductPrice getProductPrice(String communityId, String productId, String effectiveAccountId) {
        ConnectApi.ProductPrice productPrice = new ConnectApi.ProductPrice();
        productPrice.unitPrice = '1020';
        productPrice.listPrice =  '1500';   
        return productPrice;
    }
    
    //Test createCart
    public static ConnectApi.CartSummary createCart(String webstoreId, ConnectApi.CartInput cartInput){
        ConnectApi.CartSummary cartDetails = new ConnectApi.CartSummary();
        cartDetails.accountId = cartInput.effectiveAccountId;
        cartDetails.cartId = 'CART-ID-123';
        cartDetails.name = 'Test Cart';
        cartDetails.purchaseOrderNumber = 'PON10232';
        cartDetails.totalChargeAmount = '50';
        cartDetails.totalListPrice = '350';
        cartDetails.totalProductAmount = '400';
        cartDetails.webstoreId = webstoreId;
        cartDetails.status = ConnectApi.CartStatus.Active;
        return cartDetails;
    }
    
    // Get Community ID
    public static ConnectApi.CommunityPage getCommunityId(){
     	ConnectApi.CommunityPage communityPageObject = new ConnectApi.CommunityPage();
		List<ConnectApi.Community> comList = new List<ConnectApi.Community>();
        ConnectApi.Community comItem = new ConnectApi.Community();
		comItem.Id = [SELECT Id, Name, Status FROM Network WHERE Status = 'Live' LIMIT 1].Id;
        comItem.templateName = 'B2B Commerce';
		comList.add(comItem);
        communityPageObject.communities = comList;
        return communityPageObject;
        
    } 
    
    // Get OrderSummary
    public static List<OrderSummary> getOrderSummary(){
        List<OrderSummary> osList = new List<OrderSummary>();
        OrderSummary os = new OrderSummary(
		   Status = 'Draft'     
        );
        osList.add(os);
        return osList;
        
    }
    
    // Get OrderProductSummary
    public static List<OrderItemSummary> getOrderProductSummary(){
        List<OrderItemSummary> oisList = new List<OrderItemSummary>();
        OrderItemSummary ois = new OrderItemSummary(
		   Name = 'Empty OrderItemSummary'     
        );
        oisList.add(ois);
        return oisList;
        
    }
    
    // Get OrderDeliveryGroupSummary
    public static List<OrderDeliveryGroupSummary> getOrderDeliveryGroupSummary(){
        List<OrderDeliveryGroupSummary> odgsList = new List<OrderDeliveryGroupSummary>();
        OrderDeliveryGroupSummary odgs = new OrderDeliveryGroupSummary(
		   DeliverToName = 'Empty OrderDeliveryGroupSummary'     
        );
        odgsList.add(odgs);
        return odgsList;
        
    }
}