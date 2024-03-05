public class OrderSubmissionPayloadGenerator {
    public static String generatePayload(Id orderId){
        List<Order> lstOrder = new List<Order>();
        lstOrder = [Select Id,CurrencyIsoCode,GrandTotalAmount,
            TotalAdjDeliveryAmtWithTax,CreatedDate,
            LastModifiedDate,ActivatedById,
        
            (Select Id,TotalAmtWithTax,TotalTaxAmount,TotalAdjustmentAmount,
            Type from OrderItems),

            (Select Id,Email__c,PoNumber,BillingState,TotalAdjustedProductAmount,TotalAdjustedDeliveryTaxAmount 
            from OrderSummaries) 

            from Order where Id=:orderId
        ];
        
        Order objOrd = lstOrder[0];
        Double shipDiscount = 0.0;
        Double totalShippingAmt = 0.0;
        Double totalProdAmt = 0.0;
        Double orderDiscount = 0.0;
        Double totalDiscountAmt = 0.0;
        Double totalTaxAmt = 0.0;
        Integer totalItemDiscounted = 0;
        for(OrderItem objOI: objOrd.OrderItems){
            if(objOI.Type == 'Delivery Charge'){
                shipDiscount+=objOI.TotalAdjustmentAmount;
                totalShippingAmt+=objOI.TotalAmtWithTax;
            } else {
                orderDiscount+=objOI.TotalAdjustmentAmount;
                totalProdAmt+=objOI.TotalAmtWithTax;
            }
            totalDiscountAmt +=objOI.TotalAdjustmentAmount;
            totalTaxAmt +=objOI.TotalTaxAmount;
            if(objOI.TotalAdjustmentAmount > 0){
                totalItemDiscounted+=1;
            }
        }

        Set<Id> prodId = new Set<Id>();
        List<OrderItemSummary> lstOrderItemSumm = new List<OrderItemSummary>();
        lstOrderItemSumm = [Select Id,Name,Status,Quantity,TotalAdjustmentTaxAmount,TotalAdjustmentDistAmount,TotalLineAmount,TotalPrice,ListPrice,UnitPrice,CurrencyIsoCode,Product2Id,Product2.Name,Product2.ProductCode,Product2.Description from OrderItemSummary where OrderSummaryId =: objOrd.OrderSummaries[0].Id];
        for(OrderItemSummary objOISTEmp : lstOrderItemSumm){
            prodId.add(objOISTEmp.Product2Id);
        }
        List<PriceBookEntry> lstPBE = new List<PriceBookEntry>();
        lstPBE = [Select Id,Product2Id,Source_External_id__c from PriceBookEntry where CurrencyIsoCode=:lstOrderItemSumm[0].CurrencyIsoCode AND Product2Id IN:prodId];
        Map<Id,String> mapExternalProdId = new Map<Id,String>();
        for(PriceBookEntry objPBE : lstPBE){
            mapExternalProdId.put(objPBE.Product2Id,objPBE.Source_External_id__c);
        }
        Boolean orderDiscounted = orderDiscount > 0;
        Boolean taxDiscounted = shipDiscount > 0;
        Id tempId = [Select ContactId from User where Id=:objOrd.ActivatedById].ContactId;
        Id conId = tempId != null ? tempId : '0038L00000B7kq4QAB';
        Contact objCon = new Contact();
        objCon = [Select Id,FirstName,LastName,MiddleName,Email,AccountId,Account.Name,Account.AccountNumber,Account.Oracle_Account_Number__c from Contact where Id=:conId];
        OrderSubmissionWrapper objWrap = new OrderSubmissionWrapper();
        objWrap.site = new OrderSubmissionWrapper.cls_site();
        objWrap.site.siteURL = 'https://shop.zimviedental.com';
        objWrap.site.siteName = 'ZimVie Dental Shop';
        objWrap.discountInfo = new OrderSubmissionWrapper.cls_discountInfo();
        
        // Fill discount related original values
        objWrap.discountInfo.orderDiscount = orderDiscount;//orderDiscount < 0 ? Integer.valueof(orderDiscount*-1) : Integer.valueof(orderDiscount);
        objWrap.discountInfo.shippingDiscount = shipDiscount;//Integer.valueof(shipDiscount);
        objWrap.discountInfo.unclaimedCouponMultiPromotions = new OrderSubmissionWrapper.cls_unclaimedCouponMultiPromotions();
        objWrap.discountInfo.orderCouponsMap = new OrderSubmissionWrapper.cls_orderCouponsMap();
        objWrap.discountInfo.orderImplicitDiscountList = new List<OrderSubmissionWrapper.cls_orderImplicitDiscountList>();
        objWrap.discountInfo.unclaimedCouponsMap = new OrderSubmissionWrapper.cls_unclaimedCouponsMap();
        objWrap.discountInfo.claimedCouponMultiPromotions = new OrderSubmissionWrapper.cls_claimedCouponMultiPromotions();

        objWrap.order = new OrderSubmissionWrapper.cls_order();
        objWrap.order.gwp = false;
        objWrap.order.secondaryCurrencyCode = null;
        objWrap.order.x_totalShippingAmount = totalShippingAmt;//Integer.valueof(totalShippingAmt);
        objWrap.order.submittedDate = Datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        objWrap.order.salesChannel = 'default';
        objWrap.order.configuratorId = null;
        objWrap.order.organizationId = String.valueof(objCon.Account.Oracle_Account_Number__c);
        objWrap.order.relationships = new List<OrderSubmissionWrapper.cls_relationships>();
        OrderSubmissionWrapper.cls_relationships objRelationShip = new OrderSubmissionWrapper.cls_relationships();
        objRelationShip.paymentGroupId = '';
        objRelationShip.amount = 0;
        objRelationShip.relationshipType = 'ORDERAMOUNTREMAINING';
        objRelationShip.id = 'r670203';
        objWrap.order.relationships.add(objRelationShip);
        objWrap.order.exchangeRate = null;
        objWrap.order.x_state = objOrd.OrderSummaries[0].BillingState;
        objWrap.order.x_customerNumber = String.valueof(objCon.Account.Oracle_Account_Number__c);
        objWrap.order.id = orderId;
        objWrap.order.state = 'SUBMITTED';
        objWrap.order.taxCalculated = totalTaxAmt > 0;
        objWrap.order.combinedPriceInfos = null;

        //fill values in commerce items start
        
        // Add the commerce items to the root object
        objWrap.order.commerceItems = new List<OrderSubmissionWrapper.CommerceItem>();

        for(OrderItemSummary objOIS : lstOrderItemSumm){
            if(objOIS.Product2.ProductCode == null || objOIS.Product2.ProductCode == ''){
                continue;
            }
            OrderSubmissionWrapper.CommerceItem commerceItem1 = new OrderSubmissionWrapper.CommerceItem();
            commerceItem1.gwp = false;
            commerceItem1.deactivationDate = null;
            commerceItem1.returnedQuantity = 0;
            commerceItem1.availabilityDate = null;
            commerceItem1.billingProfileId = null;
            commerceItem1.externalData = new List<Object>();
            commerceItem1.billingAccountId = null;
            commerceItem1.preOrderQuantity = 0;
            commerceItem1.assetKey = null;
            commerceItem1.commerceItemId = objOIS.Id;

            commerceItem1.catalogId = null;
            commerceItem1.externalRecurringChargeDetails = new OrderSubmissionWrapper.cls_externalRecurringChargeDetails();
            commerceItem1.x_state = null;
            commerceItem1.actionCode = null;
            commerceItem1.asset = false;
            commerceItem1.backOrderQuantity = 0;
            
            commerceItem1.catalogRefId = objOIS.Product2.ProductCode;

            //
            // Get the current DateTime
            //DateTime now = DateTime.now();
            
            // Convert the DateTime to a Long value
            //Long timestamp = now.getTime();
            
            // Use the last few digits of the timestamp as the basis for generating a random number
            //Long seed = timestamp;
            
            // Generate a random number using the seed
            //Long randomNumber = Math.mod(Math.abs(Crypto.getRandomLong()), 1000000);
            
            // Add the seed to the random number to ensure uniqueness
            //Long finalNumber = timestamp + randomNumber;
            //
            commerceItem1.id = objOIS.Id;// + '-' +String.valueof(finalNumber);
            commerceItem1.serviceId = null;
            
            commerceItem1.x_discountAmount = objOIS.TotalAdjustmentDistAmount;
            commerceItem1.lineAttributes = new List<Object>();
            commerceItem1.locationInventoryInfoMap = new OrderSubmissionWrapper.cls_locationInventoryInfoMap();
            commerceItem1.pointOfNoRevision = false;
            
            commerceItem1.productDisplayName = objOIS.Product2.Description;
            
            commerceItem1.productId = objOIS.Product2.ProductCode;
            commerceItem1.parentAssetKey = null;
            
            commerceItem1.quantity = Integer.valueof(objOIS.Quantity);
            commerceItem1.shopperInput = new OrderSubmissionWrapper.cls_shopperInput();
            commerceItem1.siteId = 'siteUS';
            commerceItem1.state = 'INITIAL';
            
            commerceItem1.x_skuId = objOIS.Product2.Name == 'Shipping Charge for this delivery method' ? 'SHIPCHARGE' : objOIS.Product2.ProductCode;
            commerceItem1.x_shippedQuantity = null;
            commerceItem1.x_overnightShipping = null;
            commerceItem1.serviceAccountId = null;
            
            commerceItem1.x_discountPercentage = objOIS.TotalAdjustmentDistAmount/objOIS.TotalLineAmount;

            commerceItem1.externalId = null;
            commerceItem1.x_trackingInfo = null;
            commerceItem1.originalCommerceItemId = null;
            commerceItem1.rootAssetKey = null;
            commerceItem1.transactionDate = null;
            
            commerceItem1.x_discount = objOIS.TotalAdjustmentDistAmount;
            commerceItem1.customerAccountId = null;
            commerceItem1.recurringChargePriceInfo = null;
            commerceItem1.catalogKey = null;
            commerceItem1.activationDate = null;
            OrderSubmissionWrapper.CommerceItemPriceInfo priceInfo1 = new OrderSubmissionWrapper.CommerceItemPriceInfo();
            priceInfo1.discounted =  objOIS.TotalAdjustmentDistAmount > 0;
            priceInfo1.amount = objOIS.TotalPrice;
            priceInfo1.secondaryCurrencyShippingSurcharge = 0;
            priceInfo1.rawTotalPrice = objOIS.ListPrice;
            priceInfo1.salePrice = 0;
            priceInfo1.orderDiscountInfos = new List<Object>();
            priceInfo1.priceListId = mapExternalProdId.get(objOIS.Product2Id);
            priceInfo1.itemDiscountInfos = new List<Object>();
            priceInfo1.quantityDiscounted = 0;
            priceInfo1.amountIsFinal = false;
            priceInfo1.onSale = false;
            priceInfo1.shippingSurcharge = 0;
            priceInfo1.discountable = true;

            OrderSubmissionWrapper.CurrentPriceDetail currentPriceDetail1 = new OrderSubmissionWrapper.CurrentPriceDetail();
            currentPriceDetail1.secondaryCurrencyTaxAmount = 0;
            currentPriceDetail1.discounted = false;
            currentPriceDetail1.amount = objOIS.TotalPrice;
            currentPriceDetail1.quantity = Integer.valueof(objOIS.Quantity);
            currentPriceDetail1.configurationDiscountShare = 0;
            currentPriceDetail1.amountIsFinal = false;

            OrderSubmissionWrapper.CIRange range1 = new OrderSubmissionWrapper.CIRange();
            range1.lowBound = 0;
            range1.highBound = 5;
            range1.size = 6;

            currentPriceDetail1.range = range1;
            currentPriceDetail1.tax = objOIS.TotalAdjustmentTaxAmount;
            currentPriceDetail1.orderDiscountShare = 0;
            currentPriceDetail1.detailedUnitPrice = objOIS.UnitPrice;
            currentPriceDetail1.currencyCode = objOIS.CurrencyIsoCode;

            priceInfo1.currentPriceDetailsSorted = new List<OrderSubmissionWrapper.CurrentPriceDetail>{currentPriceDetail1};
            priceInfo1.currencyCode = objOIS.CurrencyIsoCode;
            priceInfo1.listPrice = objOIS.ListPrice;

            commerceItem1.priceInfo = priceInfo1;

            OrderSubmissionWrapper.ExternalPriceDetails externalPriceDetails1 = new OrderSubmissionWrapper.ExternalPriceDetails();
            externalPriceDetails1.externalPriceQuantity = -1;
            externalPriceDetails1.externalPrice = 84;

            commerceItem1.externalPriceDetails = externalPriceDetails1;
            
            objWrap.order.commerceItems.add(commerceItem1);
        }

        //commerce items end

        objWrap.order.x_externalOrderId = objOrd.OrderSummaries[0].Id;
        //shipping options start
        
        List<OrderDeliveryGroupSummary> shippingGroupSF = [SELECT Id, CurrencyIsoCode,TotalTaxAmount,GrandTotalAmount,
                                                            TotalAdjustmentAmount,Description,CreatedDate,OrderDeliveryMethodId,
                                                            OrderDeliveryMethod.ClassOfService,DeliverToCountryCode,
                                                            DeliverToCity,DeliverToStateCode,DeliverToPostalCode,DeliverToStreet  
                                                            FROM OrderDeliveryGroupSummary
                                                            WHERE OrderSummary.OriginalOrderId =: orderId
                                                            ORDER BY CreatedDate desc LIMIT 1];
        OrderDeliveryGroupSummary objShipingGroup = new OrderDeliveryGroupSummary();
        if(shippingGroupSF.size() > 0){
            objShipingGroup = shippingGroupSF[0];
        }

        
        CartDeliveryGroup objCDG = [Select Cart.Name,Cart.Selected_Contact_Point_Address__c from CartDeliveryGroup where DeliveryMethodId=:objShipingGroup.OrderDeliveryMethodId order by CreatedDate desc limit 1];
        String cartName = objCDG.Cart.Name;

        List<ContactPointAddress> lstPointAddress = new List<ContactPointAddress>();
        lstPointAddress = [Select Id,CountryCode,First_Name__c,City,Street,CompanyName,PostalCode,ORAAddressId__c,Last_Name__c,PhoneNumber,AddressMiddleName,StateCode from ContactPointAddress where Id=:objCDG.Cart.Selected_Contact_Point_Address__c];
        
        OrderSubmissionWrapper.ShippingGroup shippingGroup = new OrderSubmissionWrapper.ShippingGroup();
        shippingGroup.shippingMethod = objShipingGroup.OrderDeliveryMethod.ClassOfService;
        shippingGroup.description = objShipingGroup.Description;
        shippingGroup.handlingInstructions = new List<String>();
        shippingGroup.specialInstructions = new OrderSubmissionWrapper.cls_specialInstructions();
        shippingGroup.priceInfo = new OrderSubmissionWrapper.ShippingGroupPriceInfo();
        shippingGroup.priceInfo.secondaryCurrencyTaxAmount = 0;
        shippingGroup.priceInfo.discounted = objShipingGroup.TotalAdjustmentAmount > 0;
        shippingGroup.priceInfo.shippingTax = objShipingGroup.TotalTaxAmount;
        shippingGroup.priceInfo.secondaryCurrencyShippingAmount = 0;
        shippingGroup.priceInfo.amount = objShipingGroup.GrandTotalAmount;
        shippingGroup.priceInfo.rawShipping = 0;
        shippingGroup.priceInfo.amountIsFinal = false;
        shippingGroup.priceInfo.currencyCode = objShipingGroup.CurrencyIsoCode;
        shippingGroup.shippingAddress = new OrderSubmissionWrapper.ShippingAddress();
        shippingGroup.shippingAddress.country = lstPointAddress[0]?.CountryCode;
        shippingGroup.shippingAddress.lastName = lstPointAddress[0]?.Last_Name__c;
        shippingGroup.shippingAddress.address1 = lstPointAddress[0]?.Street;
        shippingGroup.shippingAddress.city = lstPointAddress[0]?.City;
        shippingGroup.shippingAddress.postalCode = lstPointAddress[0]?.PostalCode;
        shippingGroup.shippingAddress.state = lstPointAddress[0]?.StateCode;
        shippingGroup.shippingAddress.firstName = lstPointAddress[0]?.First_Name__c;
        shippingGroup.shippingAddress.phoneNumber = lstPointAddress[0]?.PhoneNumber;
        shippingGroup.shippingAddress.x_externalAddressId =String.valueof(lstPointAddress[0]?.ORAAddressId__c);
        shippingGroup.shippingAddress.prefix = null;
        shippingGroup.shippingAddress.jobTitle = null;
        shippingGroup.shippingAddress.companyName =lstPointAddress[0]?.CompanyName;
        
        shippingGroup.commerceItemRelationships = new List<OrderSubmissionWrapper.CommerceItemRelationship>();

        OrderSubmissionWrapper.CommerceItemRelationship relationship1 = new OrderSubmissionWrapper.CommerceItemRelationship();
        //shippingGroup.commerceItemRelationships.add(relationship1);

        relationship1.amount = 504;
        relationship1.quantity = 6;
        relationship1.relationshipType = 'SHIPPINGQUANTITYREMAINING';
        relationship1.commerceItemId = 'ci66000143';
        relationship1.state = 'INITIAL';
        relationship1.id = 'r670200';
        relationship1.pointOfNoRevision = false;
        relationship1.returnedQuantity = 0;
        relationship1.range = new OrderSubmissionWrapper.Range();
        relationship1.range.highBound = 5;
        relationship1.range.lowBound = 0;
        relationship1.range.size = 6;
        shippingGroup.commerceItemRelationships.add(relationship1);

        OrderSubmissionWrapper.CommerceItemRelationship relationship2 = new OrderSubmissionWrapper.CommerceItemRelationship();
        relationship2.amount = 168;
        relationship2.quantity = 2;
        relationship2.relationshipType = 'SHIPPINGQUANTITYREMAINING';
        relationship2.commerceItemId = 'ci66000144';
        relationship2.state = 'INITIAL';
        relationship2.id = 'r670201';
        relationship2.pointOfNoRevision = false;
        relationship2.returnedQuantity = 0;
        relationship2.range = new OrderSubmissionWrapper.Range();
        relationship2.range.highBound = 1;
        relationship2.range.lowBound = 0;
        relationship2.range.size = 2;
        shippingGroup.commerceItemRelationships.add(relationship2);

        OrderSubmissionWrapper.CommerceItemRelationship relationship3 = new OrderSubmissionWrapper.CommerceItemRelationship();
        relationship3.amount = 252;
        relationship3.quantity = 3;
        relationship3.relationshipType = 'SHIPPINGQUANTITYREMAINING';
        relationship3.commerceItemId = 'ci66000145';
        relationship3.state = 'INITIAL';
        relationship3.id = 'r670202';
        relationship3.pointOfNoRevision = false;
        relationship3.returnedQuantity = 0;
        relationship3.range = new OrderSubmissionWrapper.Range();
        relationship3.range.highBound = 2;
        relationship3.range.lowBound = 0;
        relationship3.range.size = 3;
        shippingGroup.commerceItemRelationships.add(relationship3);

        shippingGroup.state = 'INITIAL';
        shippingGroup.id = objShipingGroup.Id;
        shippingGroup.shippingGroupClassType = 'hardgoodShippingGroup';
        shippingGroup.stateDetail = null;
        shippingGroup.trackingNumber = null;
        shippingGroup.submittedDate = objShipingGroup.CreatedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        shippingGroup.shipOnDate = null;
        shippingGroup.actualShipDate = null;

        objWrap.order.shippingGroups = new List<OrderSubmissionWrapper.ShippingGroup>{shippingGroup};

        //shipping options end

        objWrap.order.freezeDate = null;
        objWrap.order.taxExempt = false;
        objWrap.order.x_ccExpMonth = '04';
        objWrap.order.profile = new OrderSubmissionWrapper.cls_profile();
        
        objWrap.order.profile.lastName = objCon.LastName;
        objWrap.order.profile.firstName = objCon.FirstName;

        objWrap.order.profile.customerContactId = null;
        objWrap.order.profile.loyaltyPrograms = new List<OrderSubmissionWrapper.cls_loyaltyPrograms>();
        objWrap.order.profile.shippingAddress = null;
        objWrap.order.profile.middleName = null;
        
        objWrap.order.profile.login = objCon.Email;
        objWrap.order.profile.parentOrganization = new OrderSubmissionWrapper.cls_parentOrganization();
        
        objWrap.order.profile.parentOrganization.name = objCon.Account.Name;
        objWrap.order.profile.parentOrganization.externalOrganizationId = objCon.Account.AccountNumber;
        objWrap.order.profile.parentOrganization.id = String.valueof(objCon.Account.Oracle_Account_Number__c);
        
        objWrap.order.profile.email = objCon.Email;

        objWrap.order.queuedOrderSubmitData=null;
        objWrap.order.cartName=cartName;
        objWrap.order.paymentInitiatedEmailSent=false;
        objWrap.order.payShippingInSecondaryCurrency=false;
        objWrap.order.shippingGroupCount=1;
        objWrap.order.taxExemptionCode=null;
        objWrap.order.createdByOrderId=null;
        objWrap.order.orderAction='order';
        objWrap.order.x_shippingAddressId=String.valueof(lstPointAddress[0].ORAAddressId__c);
        objWrap.order.submissionErrorMessages=new List<OrderSubmissionWrapper.cls_submissionErrorMessages>();
        objWrap.order.profileId='35229041';
        objWrap.order.activeQuoteOrderId=null;
        objWrap.order.approverIds= new List<OrderSubmissionWrapper.cls_approverIds>();
        objWrap.order.agentId=null;
        objWrap.order.lastModifiedTime=String.valueof(objOrd.LastModifiedDate.getTime());
        objWrap.order.priceGroupId='1025';
        objWrap.order.creationTime= String.valueof(objOrd.CreatedDate.getTime());
        objWrap.order.sourceSystem='Cloud Commerce';
        objWrap.order.gwpMarkers=new List<OrderSubmissionWrapper.cls_gwpMarkers>();
        objWrap.order.locale='en';
        
        List<OrderPaymentSummary> lstPaymentSumm = new List<OrderPaymentSummary>();
        lstPaymentSumm = [Select Id,(select Id,Status,GatewayAuthCode,GatewayResultCodeDescription from PaymentAuthorizations),
                            CurrencyIsoCode,CreatedDate,AuthorizationAmount,PaymentMethodId 
                            from OrderPaymentSummary  where OrderSummaryId =: objOrd.OrderSummaries[0].Id];
        OrderPaymentSummary objPaySumm = new OrderPaymentSummary();
        if(lstPaymentSumm != null && lstPaymentSumm.size() > 0){
            objPaySumm = lstPaymentSumm[0];
        }
        List<CardPaymentMethod> lstCPM = new List<CardPaymentMethod>();
        CardPaymentMethod objCPM = new CardPaymentMethod();
        lstCPM = [Select Id,CardType,CardCategory,
                            ExpiryYear,ExpiryMonth,CardLastFour ,
                            CardHolderFirstName,CardHolderLastName,PaymentMethodCountryCode,
                            PaymentMethodStateCode,PaymentMethodCity,PaymentMethodPostalCode,
                            PaymentMethodStreet,Phone from CardPaymentMethod where Id=:objPaySumm.PaymentMethodId];    

        if(lstCPM != null && lstCPM.size() > 0){
            objCPM = lstCPM[0];
        }                                    
        // Creating a PaymentProps instance
        OrderSubmissionWrapper.PaymentProps paymentProps = new OrderSubmissionWrapper.PaymentProps();
        
        paymentProps.occsSavedCardId = objPaySumm.PaymentMethodId;

        // Creating a StatusProps instance
        OrderSubmissionWrapper.StatusProps statusProps = new OrderSubmissionWrapper.StatusProps();
        statusProps.hostTransactionTimestamp = 'Wed Jun 07 11:57:37 UTC 2023';
        statusProps.responseReason = 'Successfully Tokenized';
        statusProps.responseDescription = 'Tokenized with saved card';
        statusProps.cardType = objCPM.CardType;
        statusProps.hostTransactionId = orderid+'-'+objOrd.OrderSummaries[0].Id;
        statusProps.currencyCode = objPaySumm.CurrencyIsoCode;
        statusProps.occs_tx_id = orderid+'-'+objOrd.OrderSummaries[0].Id;
        statusProps.responseCode = '201';
        statusProps.token = objPaySumm.PaymentAuthorizations != null && objPaySumm.PaymentAuthorizations.size() > 0 ? objPaySumm.PaymentAuthorizations[0].GatewayAuthCode : null;

        // Creating an AuthorizationStatus instance
        OrderSubmissionWrapper.AuthorizationStatus authorizationStatus = new OrderSubmissionWrapper.AuthorizationStatus();
        authorizationStatus.amount = objPaySumm.AuthorizationAmount;
        authorizationStatus.statusProps = statusProps;
        authorizationStatus.transactionSuccess = objPaySumm.PaymentAuthorizations != null  && objPaySumm.PaymentAuthorizations.size() > 0  ? objPaySumm.PaymentAuthorizations[0].Status == 'Processed' : false;
        authorizationStatus.errorMessage = null;
        authorizationStatus.transactionId = orderid+'-'+objOrd.OrderSummaries[0].Id;

        // Creating a BillingAddress instance
        OrderSubmissionWrapper.BillingAddress billingAddress = new OrderSubmissionWrapper.BillingAddress();
        billingAddress.country = objCPM.PaymentMethodCountryCode;
        billingAddress.lastName = objCPM.CardHolderLastName;
        billingAddress.city = objCPM.PaymentMethodCity;
        billingAddress.address1 = objCPM.PaymentMethodStreet;
        billingAddress.postalCode = objCPM.PaymentMethodPostalCode;
        billingAddress.state = objCPM.PaymentMethodStateCode;
        billingAddress.firstName = objCPM.CardHolderFirstName;
        billingAddress.phoneNumber = objCPM.Phone;

        // Creating a PaymentGroup instance
        OrderSubmissionWrapper.PaymentGroup paymentGroup = new OrderSubmissionWrapper.PaymentGroup();
        paymentGroup.expirationYear = String.valueof(objCPM.ExpiryYear);
        paymentGroup.amountAuthorized = objPaySumm.AuthorizationAmount;
        paymentGroup.amount = objPaySumm.AuthorizationAmount;
        paymentGroup.gatewayName = 'ZBCybersourcePaymentGateway';
        paymentGroup.paymentProps = paymentProps;
        paymentGroup.expirationMonth = String.valueof(objCPM.ExpiryMonth);
        paymentGroup.submittedDate = objPaySumm.CreatedDate?.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        paymentGroup.authorizationStatus = new List<OrderSubmissionWrapper.AuthorizationStatus>{authorizationStatus};
        paymentGroup.IIN = '379756';
        paymentGroup.paymentGroupClassType = objCPM.CardCategory;
        paymentGroup.creditCardNumber = String.valueof(objCPM.CardLastFour);
        paymentGroup.paymentMethod = objCPM.CardCategory;
        paymentGroup.state = objPaySumm.PaymentAuthorizations != null  && objPaySumm.PaymentAuthorizations.size() > 0 ? objPaySumm.PaymentAuthorizations[0].GatewayResultCodeDescription : null;
        paymentGroup.id = objPaySumm.Id;
        paymentGroup.billingAddress = billingAddress;
        paymentGroup.currencyCode = objPaySumm.CurrencyIsoCode;
        paymentGroup.debitStatus = new List<Object>();
        // Adding the PaymentGroup to the list
        objWrap.order.paymentGroups = new List<OrderSubmissionWrapper.PaymentGroup>{paymentGroup};

        // Creating a PriceInfo instance
        OrderSubmissionWrapper.PriceInfo priceInfo = new OrderSubmissionWrapper.PriceInfo();
        priceInfo.secondaryCurrencyTaxAmount = 0;
        priceInfo.discounted = orderDiscounted;
        priceInfo.secondaryCurrencyShippingAmount = 0;
        priceInfo.amount = objOrd.GrandTotalAmount;
        priceInfo.secondaryCurrencyTotal = 0;
        priceInfo.manualAdjustmentTotal = 0;
        priceInfo.discountAmount = totalDiscountAmt;//totalDiscountAmt < 0 ? Integer.valueof(totalDiscountAmt*-1) : Integer.valueof(totalDiscountAmt);
        priceInfo.tax = totalTaxAmt;
        priceInfo.rawSubtotal = totalProdAmt;
        priceInfo.total = objOrd.GrandTotalAmount;
        priceInfo.shipping = totalShippingAmt;
        priceInfo.primaryCurrencyTotal = objOrd.GrandTotalAmount;
        priceInfo.amountIsFinal = false;
        priceInfo.orderTotalBySite = new Map<String, Decimal>{'siteUS' => objOrd.GrandTotalAmount};
        priceInfo.currencyCode = objOrd.CurrencyIsoCode;

        // Adding the PriceInfo
        objWrap.order.priceInfo = priceInfo;


        // Creating a TaxPriceInfo instance
        OrderSubmissionWrapper.TaxPriceInfo taxPriceInfo = new OrderSubmissionWrapper.TaxPriceInfo();
        taxPriceInfo.secondaryCurrencyTaxAmount = 0;
        taxPriceInfo.discounted = taxDiscounted;
        taxPriceInfo.valueAddedTax = 0;
        taxPriceInfo.amount = totalTaxAmt;
        taxPriceInfo.countyTax = 0;
        taxPriceInfo.isTaxIncluded = totalTaxAmt > 0;
        taxPriceInfo.miscTax = 0;
        taxPriceInfo.districtTax = 0;
        taxPriceInfo.stateTax = 0;
        taxPriceInfo.miscTaxInfo = new Map<String, Decimal>{'Sales Tax' => 0};
        taxPriceInfo.countryTax = 0;
        taxPriceInfo.cityTax = 0;
        taxPriceInfo.amountIsFinal = false;

        taxPriceInfo.currencyCode = objOrd.CurrencyIsoCode;

        // Adding the TaxPriceInfo
        objWrap.order.taxPriceInfo = taxPriceInfo;

        objWrap.order.payTaxInSecondaryCurrency = false;
        objWrap.order.submissionProgress = new List<Object>();
        objWrap.order.catalogId = null;
        objWrap.order.x_ccExpYear = '2028';
        objWrap.order.x_shippingDiscountAmnt = objOrd.TotalAdjDeliveryAmtWithTax;
        objWrap.order.totalCommerceItemCount = lstOrderItemSumm.size();
        objWrap.order.externalContext = false;
        objWrap.order.cancelReason = null;
        objWrap.order.quoteInfo = null;
        objWrap.order.x_paymentTerms = null;
        objWrap.order.creationSiteId = 'siteUS';
        objWrap.order.allowAlternateCurrency = false;
        objWrap.order.x_poNumber = objOrd.OrderSummaries[0].PoNumber;
        objWrap.order.approverMessages = new List<Object>();
        //pending
        objWrap.order.x_externalShippingMethodId = objShipingGroup.OrderDeliveryMethod.ClassOfService;
        objWrap.order.orderUpdationRemarks = null;
        objWrap.order.paymentGroupCount = 1;
        objWrap.order.x_subtotal = objOrd.OrderSummaries[0].TotalAdjustedProductAmount;
        objWrap.order.x_totalItemDiscountOnOrder = totalItemDiscounted;
        objWrap.order.submissionErrorCodes = new List<Object>();
        objWrap.order.recurringChargePriceInfo = null;
        objWrap.order.x_shippingTax = objOrd.OrderSummaries[0].TotalAdjustedDeliveryTaxAmount;

        // Creating an Organization instance
        OrderSubmissionWrapper.Organization organization = new OrderSubmissionWrapper.Organization();
        organization.repositoryId = String.valueof(objCon.Account.Oracle_Account_Number__c);
        organization.name = objCon.Account.Name;
        organization.active = true;
        organization.externalOrganizationId = '';
        organization.id = String.valueof(objCon.Account.Oracle_Account_Number__c);

        // Adding the Organization
        objWrap.order.organization = organization;

        objWrap.order.siteId = 'siteUS';
        objWrap.order.markers = new List<Object>();

        return JSON.serialize(objWrap);
    }
}