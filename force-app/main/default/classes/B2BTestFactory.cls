@isTest
public class B2BTestFactory {
    public static Map<String, String> initialStorefrontSetup() {
        Map<String, String> response = new Map<String, String>();
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Sales Contact').getRecordTypeId();
            ProductCatalog prodCatalog = new ProductCatalog();
            prodCatalog.Name = 'Test Catalog';
            insert prodCatalog;
            
            WebStore webStr = new WebStore();
            webStr.Name = 'Mkf Store';
            webStr.PricingStrategy = 'LowestPrice';
            insert webStr;
            
            WebStoreCatalog web_Catalog = new WebStoreCatalog();
            web_Catalog.SalesStoreId = webStr.Id;
            web_Catalog.ProductCatalogId = prodCatalog.Id;
            insert web_Catalog;
            
            ProductCategory parent_category = new ProductCategory();
            parent_category.Name = 'ParentCategory';
            parent_category.CatalogId = prodCatalog.Id;
            parent_category.Description = 'Description';
            insert parent_category;
            
            ProductCategory prod_category = new ProductCategory();
            prod_category.Name = 'ProductCategory';
            prod_category.IsNavigational = True;
            prod_category.SortOrder = 4;
            prod_category.ParentCategoryId = parent_category.Id;
            prod_category.Description = 'Description';
            prod_category.CatalogId = prodCatalog.Id;
            insert prod_category;
            
            ProductCategory prod_category2 = new ProductCategory();
            prod_category2.Name = 'Marktest';
            prod_category2.IsNavigational = True;
            prod_category2.SortOrder = 4;
            prod_category2.ParentCategoryId = parent_category.Id;
            prod_category2.Description = 'Description';
            prod_category2.CatalogId = prodCatalog.Id;
            insert prod_category2; 
            
            ProductCategory prod_category3 = new ProductCategory();
            prod_category3.Name = 'Test printer';
            prod_category3.IsNavigational = True;
            prod_category3.SortOrder = 4;
            prod_category3.ParentCategoryId = parent_category.Id;
            prod_category3.Description = 'Description';
            prod_category3.CatalogId = prodCatalog.Id;
            insert prod_category3;             
            
            BuyerGroup buyGrp = addNewBuyerGroup('Test', true);
            
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
            
            Pricebook2 newPricebook = new Pricebook2(
                Name = 'Test Book',
                IsActive = true
            );
            insert newPricebook;
            
            Schema.Location loc = new Schema.Location();
            loc.Name = 'Test Location';
            loc.LocationType ='Site';
            insert loc;
            
            Product2 proParentCertification = new Product2(
                IsActive = true,
                Name = 'Parent Certification',
                CurrencyIsoCode = 'USD',
                Family = 'Syndicated',
                ProductCode = 'CERTIFICATION'
            );    
            insert proParentCertification;        
            
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
                Product2Id = proParentCertification.Id,
                UnitPrice = 1020,
                IsActive = true
            );
            insert pbe1;
            
            CommerceEntitlementProduct commerceEntProduct = new CommerceEntitlementProduct(
                PolicyId = commerceEntPolicy.Id,
                ProductId = proParentCertification.Id
            );
            insert commerceEntProduct;
            
            ContactPointAddress con_point = new ContactPointAddress();
            con_point.Name = 'Test Address 123';
            con_point.City = 'Goleta';
            con_point.PostalCode = '93117-3084';
            con_point.State = 'California';
            con_point.Country = 'United States';
            con_point.AddressType = 'shipping/Billing';
            con_point.ActiveFromDate = Date.newInstance(2019, 12, 9);
            con_point.ActiveToDate = Date.newInstance(2021, 12, 9);
            insert con_point;
            
            Account acc = new Account();
            acc.Name = 'Test Name';
            acc.Type = 'Customer';
            acc.ShippingCountry = 'United States';
            acc.ShippingState = 'Alabama';
            acc.ShippingPostalCode = '12345';
            acc.BillingStreet  = 'Cambridge';
            acc.BillingCity   = 'Cambridge';
            acc.BillingCountry   = 'United States';
            insert acc;
            
            ContactPointAddress cpa = new ContactPointAddress();
            cpa.Name='Test CPA';
            cpa.AddressType='Billing';
            cpa.Street='TestStreet';
            cpa.City='TestCity';
            cpa.State='Alabama';
            cpa.Country='United States';
            cpa.PostalCode='10013';
            cpa.IsDefault=true;
            cpa.ParentId=acc.Id;        
            insert cpa;    
            
            Contact con = new Contact();
            con.FirstName = 'test';
            con.LastName = 'Contact';
            con.Email = 'test@test.com';
            con.AccountId = acc.Id;
            con.RecordTypeId = devRecordTypeId;
            insert con;    
            
            BuyerAccount buyrAcc = new BuyerAccount();
            buyrAcc.Name = acc.Name;
            buyrAcc.BuyerId = acc.Id;
            buyrAcc.IsActive = true;
            insert buyrAcc;  
            
            BuyerGroupMember buyGrpMem = new BuyerGroupMember();
            buyGrpMem.BuyerId = acc.Id;
            buyGrpMem.BuyerGroupId = buyGrp.Id;
            insert buyGrpMem;            
            
            Profile pf = [SELECT Id FROM Profile WHERE Name = 'B2B Lightning Community Plus' LIMIT 1];
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
                               ContactId = con.Id,
                               PortalRole = 'Manager'
                              );
            insert uu;
            
            WebCart cart = new WebCart(Name = 'current', WebStoreId = webStr.Id, AccountId = acc.Id , Status = 'Active', OwnerId = uu.Id);
            INSERT cart;
            
            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId = cart.Id, Name = 'Default Delivery');
            INSERT cartDeliveryGroup;
            
            List<CartItem>cartItems = new List<CartItem>();
            CartItem cart1 = new CartItem(
                CartId = cart.Id, 
                Sku = 'SKU_Test1', 
                SalesPrice = 10.00, 
                Quantity = 3.0, 
                Type = 'Product', 
                Name ='TestProduct', 
                CartDeliveryGroupId=cartDeliveryGroup.Id, 
                Product2Id = proParentCertification.Id);
            
            CartItem cart2 = new CartItem(
                CartId = cart.Id, 
                Sku = 'SKU_Test1', 
                SalesPrice = 10.00, 
                Quantity = 3.0, 
                Type = 'Product', 
                Name ='TestProduct', 
                CartDeliveryGroupId = cartDeliveryGroup.Id, 
                Product2Id = proParentCertification.Id);
            cartItems.add(cart1);
            cartItems.add(cart2);
            INSERT cartItems;
            
            CartCheckoutSession checkoutSession = new CartCheckoutSession(WebCartId = cart.Id, IsArchived = FALSE, State = 'Start', Name = cart.Id);
            INSERT checkoutSession;
            
            response.put('userId', uu.Id);
            response.put('accountId', acc.Id);
            response.put('contactId', con.Id);
            response.put('accountId', acc.Id);
            response.put('Cartid',cart.id);
            
            
            response.put('productId', proParentCertification.Id);
            response.put('webStoreName', webStr.Name);
            response.put('webStoreId', webStr.Id);
            response.put('productCategoryId',prod_category.Id);
            response.put('webCatalogId',web_Catalog.Id);
            response.put('pricebookEntryId', pbe1.Id);
            response.put('pricebookId', standardPricebook.Id);
        }
        return response;
    }
    public static BuyerGroup addNewBuyerGroup(String name,Boolean isInsert) {
        BuyerGroup buyGrp;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            buyGrp = new BuyerGroup();
            buyGrp.Name = String.isNotBlank(name) ? name : 'JAN22PROMO';
            if(isInsert) { insert buyGrp;}
        }
        return buyGrp;
    }	
}