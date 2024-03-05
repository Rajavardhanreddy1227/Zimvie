public class B2BOrderService {
	@InvocableMethod(label='submit Order to oracle')
    public static void orderSync(List<orderRequest> orderReq) {
		final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.ORDER_CONFIRMATION);
		try {
			String orderSummaryStatus = [Select Status from OrderSummary where Id=:orderReq[0].orderSummId].Status;
			if(orderSummaryStatus != 'Cancelled'){
				String jsonBody = OrderSubmissionPayloadGenerator.generatePayload(orderReq[0].orderId);//generateJSON(null);
				//sendSingleEmailMethod(jsonBody);
				System.enqueueJob(new B2BOrderServiceRetryable(jsonBody,orderReq[0].orderSummId));
			}
			
		} catch (Exception ex) {
			logger.error(ex);
		} finally {
			logger.flush();
		}
        
    }

	public class orderRequest{
        @InvocableVariable
        public Id orderId;
		@InvocableVariable
        public Id orderSummId;
    }
	
	/*public static void sendSingleEmailMethod(String body){
		Messaging.reserveSingleEmailCapacity(2);
		Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
		String[] toaddresses = new String[] {'akash.arora@rafter.one'}; 
		
		mymail.setToAddresses(toAddresses);
		mymail.setReplyTo('support@example.com');
		mymail.setSenderDisplayName('Salesforce Support');
		mymail.setSubject('An email from Salesforce');
		mymail.setPlainTextBody(body);
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mymail });
	}*/
    public static String generateJSON(String orderId){ 
        String json=		'{'+
		'    "discountInfo": {'+
		'        "claimedCouponMultiPromotions": {'+
		'        },'+
		'        "orderCouponsMap": {'+
		'        },'+
		'        "orderDiscount": 0,'+
		'        "orderImplicitDiscountList": ['+
		'        ],'+
		'        "shippingDiscount": 0,'+
		'        "unclaimedCouponMultiPromotions": {'+
		'        },'+
		'        "unclaimedCouponsMap": {'+
		'        }'+
		'    },'+
		'    "order": {'+
		'        "activeQuoteOrderId": null,'+
		'        "agentId": null,'+
		'        "allowAlternateCurrency": false,'+
		'        "approverIds": ['+
		'        ],'+
		'        "approverMessages": ['+
		'        ],'+
		'        "cancelReason": null,'+
		'        "cartName": null,'+
		'        "catalogId": null,'+
		'        "combinedPriceInfos": null,'+
		'        "commerceItems": ['+
		'            {'+
		'                "actionCode": null,'+
		'                "activationDate": null,'+
		'                "asset": false,'+
		'                "assetKey": null,'+
		'                "availabilityDate": null,'+
		'                "backOrderQuantity": 0,'+
		'                "billingAccountId": null,'+
		'                "billingProfileId": null,'+
		'                "catalogId": null,'+
		'                "catalogKey": null,'+
		'                "catalogRefId": "IMHA34",'+
		'                "commerceItemId": "ci66000143",'+
		'                "customerAccountId": null,'+
		'                "deactivationDate": null,'+
		'                "externalData": ['+
		'                ],'+
		'                "externalId": null,'+
		'                "externalPriceDetails": {'+
		'                    "externalPrice": 84,'+
		'                    "externalPriceQuantity": -1'+
		'                },'+
		'                "externalRecurringChargeDetails": {'+
		'                },'+
		'                "gwp": false,'+
		'                "id": "ci66000143",'+
		'                "lineAttributes": ['+
		'                ],'+
		'                "locationInventoryInfoMap": {'+
		'                },'+
		'                "originalCommerceItemId": null,'+
		'                "parentAssetKey": null,'+
		'                "pointOfNoRevision": false,'+
		'                "preOrderQuantity": 0,'+
		'                "priceInfo": {'+
		'                    "amount": 504,'+
		'                    "amountIsFinal": false,'+
		'                    "currencyCode": "USD",'+
		'                    "currentPriceDetailsSorted": ['+
		'                        {'+
		'                            "amount": 504,'+
		'                            "amountIsFinal": false,'+
		'                            "configurationDiscountShare": 0,'+
		'                            "currencyCode": "USD",'+
		'                            "detailedUnitPrice": 84,'+
		'                            "discounted": false,'+
		'                            "orderDiscountShare": 0,'+
		'                            "quantity": 6,'+
		'                            "range": {'+
		'                                "highBound": 5,'+
		'                                "lowBound": 0,'+
		'                                "size": 6'+
		'                            },'+
		'                            "secondaryCurrencyTaxAmount": 0,'+
		'                            "tax": 0'+
		'                        }'+
		'                    ],'+
		'                    "discountable": true,'+
		'                    "discounted": false,'+
		'                    "itemDiscountInfos": ['+
		'                    ],'+
		'                    "listPrice": 84,'+
		'                    "onSale": false,'+
		'                    "orderDiscountInfos": ['+
		'                    ],'+
		'                    "priceListId": "1025_listPrices",'+
		'                    "quantityDiscounted": 0,'+
		'                    "rawTotalPrice": 504,'+
		'                    "salePrice": 0,'+
		'                    "secondaryCurrencyShippingSurcharge": 0,'+
		'                    "shippingSurcharge": 0'+
		'                },'+
		'                "productDisplayName": "Certain<sup>®</sup> Straight EP 1-PC Healing Abutment",'+
		'                "productId": "ISMHA",'+
		'                "quantity": 6,'+
		'                "recurringChargePriceInfo": null,'+
		'                "returnedQuantity": 0,'+
		'                "rootAssetKey": null,'+
		'                "serviceAccountId": null,'+
		'                "serviceId": null,'+
		'                "shopperInput": {'+
		'                },'+
		'                "siteId": "siteUS",'+
		'                "state": "INITIAL",'+
		'                "transactionDate": null,'+
		'                "x_discount": null,'+
		'                "x_discountAmount": null,'+
		'                "x_discountPercentage": null,'+
		'                "x_overnightShipping": null,'+
		'                "x_shippedQuantity": null,'+
		'                "x_skuId": "IMHA34",'+
		'                "x_state": null,'+
		'                "x_trackingInfo": null'+
		'            }'+
		'        ],'+
		'        "configuratorId": null,'+
		'        "createdByOrderId": null,'+
		'        "creationSiteId": "siteUS",'+
		'        "creationTime": "1689590708000",'+
		'        "exchangeRate": null,'+
		'        "externalContext": false,'+
		'        "freezeDate": null,'+
		'        "gwp": false,'+
		'        "gwpMarkers": ['+
		'        ],'+
		'        "id": "580121",'+
		'        "lastModifiedTime": "1691668557000",'+
		'        "locale": "en",'+
		'        "markers": ['+
		'        ],'+
		'        "orderAction": "order",'+
		'        "orderUpdationRemarks": null,'+
		'        "organization": {'+
		'            "active": true,'+
		'            "externalOrganizationId": "149364",'+
		'            "id": "TESTB2BACC",'+
		'            "name": "B2B-Test Account",'+
		'            "repositoryId": "9876543"'+
		'        },'+
		'        "organizationId": "9876543",'+
		'        "paymentGroupCount": 1,'+
		'        "paymentGroups": ['+
		'            {'+
		'                "amount": 924,'+
		'                "amountAuthorized": 924,'+
		'                "authorizationStatus": ['+
		'                    {'+
		'                        "amount": 924,'+
		'                        "errorMessage": null,'+
		'                        "statusProps": {'+
		'                            "cardType": "amex",'+
		'                            "currencyCode": "USD",'+
		'                            "hostTransactionId": "580121-pg650061-1686139057545",'+
		'                            "hostTransactionTimestamp": "Wed Jun 07 11:57:37 UTC 2023",'+
		'                            "occs_tx_id": "580121-pg650061-1686139057545",'+
		'                            "responseCode": "1000",'+
		'                            "responseDescription": "Tokenized with saved card",'+
		'                            "responseReason": "Successfully Tokenized",'+
		'                            "token": "0333581336892002"'+
		'                        },'+
		'                        "transactionId": "580121-pg650061-1686139057545",'+
		'                        "transactionSuccess": true'+
		'                    }'+
		'                ],'+
		'                "billingAddress": {'+
		'                    "address1": "150 Cedar Lane",'+
		'                    "address2": null,'+
		'                    "address3": null,'+
		'                    "city": "Closter",'+
		'                    "companyName": null,'+
		'                    "country": "US",'+
		'                    "county": null,'+
		'                    "email": null,'+
		'                    "faxNumber": null,'+
		'                    "firstName": "Jay",'+
		'                    "jobTitle": null,'+
		'                    "lastName": "Greenfield",'+
		'                    "middleName": null,'+
		'                    "ownerId": null,'+
		'                    "phoneNumber": "9173711572",'+
		'                    "postalCode": "07624",'+
		'                    "prefix": null,'+
		'                    "state": "NJ",'+
		'                    "suffix": null,'+
		'                    "x_externalAddressId": null'+
		'                },'+
		'                "creditCardNumber": "2002",'+
		'                "currencyCode": "USD",'+
		'                "debitStatus": ['+
		'                ],'+
		'                "expirationMonth": "04",'+
		'                "expirationYear": "2028",'+
		'                "gatewayName": "ZBCybersourcePaymentGateway",'+
		'                "id": "pg650061",'+
		'                "IIN": "379756",'+
		'                "paymentGroupClassType": "creditCard",'+
		'                "paymentMethod": "creditCard",'+
		'                "paymentProps": {'+
		'                    "occsSavedCardId": "usercc380070"'+
		'                },'+
		'                "state": "AUTHORIZED",'+
		'                "submittedDate": "2023-06-07T11:57:38.000Z"'+
		'            }'+
		'        ],'+
		'        "paymentInitiatedEmailSent": false,'+
		'        "payShippingInSecondaryCurrency": false,'+
		'        "payTaxInSecondaryCurrency": false,'+
		'        "priceGroupId": "1025",'+
		'        "priceInfo": {'+
		'            "amount": 597,'+
		'            "amountIsFinal": false,'+
		'            "currencyCode": "USD",'+
		'            "discountAmount": 0,'+
		'            "discounted": false,'+
		'            "manualAdjustmentTotal": 0,'+
		'            "orderTotalBySite": {'+
		'                "siteUS": 597'+
		'            },'+
		'            "primaryCurrencyTotal": 597,'+
		'            "rawSubtotal": 518,'+
		'            "secondaryCurrencyShippingAmount": 0,'+
		'            "secondaryCurrencyTaxAmount": 0,'+
		'            "secondaryCurrencyTotal": 0,'+
		'            "shipping": 78,'+
		'            "tax": 44,'+
		'            "total": 597'+
		'        },'+
		'        "profile": {'+
		'            "customerContactId": null,'+
		'            "email": "ganeshkumar@rafter.one",'+
		'            "firstName": "Lauren",'+
		'            "lastName": "Bailey",'+
		'            "login": "ganeshkumar@rafter.one",'+
		'            "loyaltyPrograms": ['+
		'            ],'+
		'            "middleName": "Test",'+
		'            "parentOrganization": {'+
		'                "externalOrganizationId": "TESTB2BACC",'+
		'                "id": "9876543",'+
		'                "name": "B2B-Test Account"'+
		'            },'+
		'            "shippingAddress": null'+
		'        },'+
		'        "profileId": "35229041",'+
		'        "queuedOrderSubmitData": null,'+
		'        "quoteInfo": null,'+
		'        "recurringChargePriceInfo": null,'+
		'        "relationships": ['+
		'            {'+
		'                "amount": 0,'+
		'                "id": "r670203",'+
		'                "paymentGroupId": "pg650061",'+
		'                "relationshipType": "ORDERAMOUNTREMAINING"'+
		'            }'+
		'        ],'+
		'        "salesChannel": "default",'+
		'        "secondaryCurrencyCode": null,'+
		'        "shippingGroupCount": 1,'+
		'        "shippingGroups": ['+
		'            {'+
		'                "actualShipDate": null,'+
		'                "commerceItemRelationships": ['+
		'                    {'+
		'                        "amount": 504,'+
		'                        "availablePickupDate": null,'+
		'                        "commerceItemExternalId": null,'+
		'                        "commerceItemId": "ci66000143",'+
		'                        "id": "r670200",'+
		'                        "inventoryLocationId": null,'+
		'                        "pointOfNoRevision": false,'+
		'                        "preferredPickupDate": null,'+
		'                        "quantity": 6,'+
		'                        "range": {'+
		'                            "highBound": 5,'+
		'                            "lowBound": 0,'+
		'                            "size": 6'+
		'                        },'+
		'                        "relationshipType": "SHIPPINGQUANTITYREMAINING",'+
		'                        "returnedQuantity": 0,'+
		'                        "state": "INITIAL"'+
		'                    },'+
		'                    {'+
		'                        "amount": 168,'+
		'                        "availablePickupDate": null,'+
		'                        "commerceItemExternalId": null,'+
		'                        "commerceItemId": "ci66000144",'+
		'                        "id": "r670201",'+
		'                        "inventoryLocationId": null,'+
		'                        "pointOfNoRevision": false,'+
		'                        "preferredPickupDate": null,'+
		'                        "quantity": 2,'+
		'                        "range": {'+
		'                            "highBound": 1,'+
		'                            "lowBound": 0,'+
		'                            "size": 2'+
		'                        },'+
		'                        "relationshipType": "SHIPPINGQUANTITYREMAINING",'+
		'                        "returnedQuantity": 0,'+
		'                        "state": "INITIAL"'+
		'                    },'+
		'                    {'+
		'                        "amount": 252,'+
		'                        "availablePickupDate": null,'+
		'                        "commerceItemExternalId": null,'+
		'                        "commerceItemId": "ci66000145",'+
		'                        "id": "r670202",'+
		'                        "inventoryLocationId": null,'+
		'                        "pointOfNoRevision": false,'+
		'                        "preferredPickupDate": null,'+
		'                        "quantity": 3,'+
		'                        "range": {'+
		'                            "highBound": 2,'+
		'                            "lowBound": 0,'+
		'                            "size": 3'+
		'                        },'+
		'                        "relationshipType": "SHIPPINGQUANTITYREMAINING",'+
		'                        "returnedQuantity": 0,'+
		'                        "state": "INITIAL"'+
		'                    }'+
		'                ],'+
		'                "description": "sg640123",'+
		'                "handlingInstructions": ['+
		'                ],'+
		'                "id": "sg640123",'+
		'                "priceInfo": {'+
		'                    "amount": 0,'+
		'                    "amountIsFinal": false,'+
		'                    "currencyCode": "USD",'+
		'                    "discounted": false,'+
		'                    "rawShipping": 0,'+
		'                    "secondaryCurrencyShippingAmount": 0,'+
		'                    "secondaryCurrencyTaxAmount": 0,'+
		'                    "shippingTax": 0'+
		'                },'+
		'                "shipOnDate": null,'+
		'                "shippingAddress": {'+
		'                    "address1": "223 Lenox Avenue",'+
		'                    "address2": null,'+
		'                    "address3": null,'+
		'                    "city": "Westfield",'+
		'                    "companyName": null,'+
		'                    "country": "US",'+
		'                    "county": null,'+
		'                    "email": null,'+
		'                    "faxNumber": null,'+
		'                    "firstName": "Jay",'+
		'                    "jobTitle": null,'+
		'                    "lastName": "Greenfield",'+
		'                    "middleName": null,'+
		'                    "ownerId": null,'+
		'                    "phoneNumber": "(908) 232-8228",'+
		'                    "postalCode": "07090",'+
		'                    "prefix": null,'+
		'                    "state": "NJ",'+
		'                    "suffix": null,'+
		'                    "x_externalAddressId": "147826"'+
		'                },'+
		'                "shippingGroupClassType": "hardgoodShippingGroup",'+
		'                "shippingMethod": "sm10006",'+
		'                "specialInstructions": {'+
		'                },'+
		'                "state": "INITIAL",'+
		'                "stateDetail": null,'+
		'                "submittedDate": null,'+
		'                "trackingNumber": null'+
		'            }'+
		'        ],'+
		'        "siteId": "siteUS",'+
		'        "sourceSystem": "Cloud Commerce",'+
		'        "state": "SUBMITTED",'+
		'        "submissionErrorCodes": ['+
		'        ],'+
		'        "submissionErrorMessages": ['+
		'        ],'+
		'        "submissionProgress": ['+
		'        ],'+
		'        "submittedDate": "2023-06-07T11:57:38.000Z",'+
		'        "taxCalculated": true,'+
		'        "taxExempt": false,'+
		'        "taxExemptionCode": null,'+
		'        "taxPriceInfo": {'+
		'            "amount": 44,'+
		'            "amountIsFinal": false,'+
		'            "cityTax": 0,'+
		'            "countryTax": 0,'+
		'            "countyTax": 0,'+
		'            "currencyCode": "USD",'+
		'            "discounted": false,'+
		'            "districtTax": 0,'+
		'            "isTaxIncluded": true,'+
		'            "miscTax": 0,'+
		'            "miscTaxInfo": {'+
		'                "Sales Tax": 0'+
		'            },'+
		'            "secondaryCurrencyTaxAmount": 0,'+
		'            "stateTax": 0,'+
		'            "valueAddedTax": 0'+
		'        },'+
		'        "totalCommerceItemCount": 2,'+
		'        "x_ccExpMonth": "04",'+
		'        "x_ccExpYear": "2028",'+
		'        "x_customerNumber": "9876543",'+
		'        "x_externalOrderId": "1Os8L000000Go74SAC",'+
		'        "x_externalShippingMethodId": "FED2PM",'+
		'        "x_paymentTerms": null,'+
		'        "x_poNumber": "po56564",'+
		'        "x_shippingAddressId": "35249397",'+
		'        "x_shippingDiscountAmnt": 78,'+
		'        "x_shippingTax": 5,'+
		'        "x_state": "California",'+
		'        "x_subtotal": 480,'+
		'        "x_totalItemDiscountOnOrder": 0,'+
		'        "x_totalShippingAmount": 78'+
		'    },'+
		'    "site": {'+
		'        "siteName": "ZimVie Dental Shop",'+
		'        "siteURL": "https://shop.zimviedental.com"'+
		'    }'+
		'}';
		return json;
    }
}