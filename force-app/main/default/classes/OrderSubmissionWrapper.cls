public class OrderSubmissionWrapper{
	public cls_site site;
	public cls_discountInfo discountInfo;
	public cls_order order;
	public class cls_site {
		public String siteURL;	//https://shop.zimviedental.com
		public String siteName;	//ZimVie Dental Shop
	}
	public class cls_discountInfo {
		public cls_unclaimedCouponMultiPromotions unclaimedCouponMultiPromotions;
		public cls_orderCouponsMap orderCouponsMap;
		public Decimal orderDiscount;	//0
		public Decimal shippingDiscount;	//0
		public cls_orderImplicitDiscountList[] orderImplicitDiscountList;
		public cls_unclaimedCouponsMap unclaimedCouponsMap;
		public cls_claimedCouponMultiPromotions claimedCouponMultiPromotions;
	}
	public class cls_unclaimedCouponMultiPromotions {
	}
	public class cls_orderCouponsMap {
	}
	public class cls_orderImplicitDiscountList {
	}
	public class cls_unclaimedCouponsMap {
	}
	public class cls_claimedCouponMultiPromotions {
	}
	public class cls_order {
		public boolean gwp;
		public String secondaryCurrencyCode;
		public Decimal x_totalShippingAmount;	//18
		public String submittedDate;	//2023-06-07T11:57:38.000Z
		public String salesChannel;	//default
		public String configuratorId;
		public String organizationId;	//1300019
		public cls_relationships[] relationships;
		public String exchangeRate;
		public String x_state;
		public String x_customerNumber;	//1300019
		public String id;	//580121
		public String state;	//SUBMITTED
		public boolean taxCalculated;
		public string combinedPriceInfos;
		public List<CommerceItem> commerceItems;
		public string x_externalOrderId;
		public List<ShippingGroup> shippingGroups;
		public string freezeDate;
		public boolean taxExempt;
		public String x_ccExpMonth;	//04
		public cls_profile profile;
		public string queuedOrderSubmitData;
		public string cartName;
		public boolean paymentInitiatedEmailSent;
		public boolean payShippingInSecondaryCurrency;
		public Integer shippingGroupCount;	//1
		public string taxExemptionCode;
		public string createdByOrderId;
		public String orderAction;	//order
		public String x_shippingAddressId;	//35249397
		public cls_submissionErrorMessages[] submissionErrorMessages;
		public String profileId;	//35229041
		public string activeQuoteOrderId;
		public cls_approverIds[] approverIds;
		public string agentId;
		public String lastModifiedTime;	//1686139058210
		public String priceGroupId;	//1025
		public String creationTime;	//1686138983000
		public String sourceSystem;	//Cloud Commerce
		public cls_gwpMarkers[] gwpMarkers;
		public String locale;	//en
		public List<PaymentGroup> paymentGroups;
		public Boolean payTaxInSecondaryCurrency;
		public PriceInfo priceInfo;
		public List<Object> submissionProgress;
		public String catalogId;
		public String x_ccExpYear;
		public Decimal x_shippingDiscountAmnt;
		public Integer totalCommerceItemCount;
		public Boolean externalContext;
		public String cancelReason;
		public Object quoteInfo;
		public String x_paymentTerms;
		public TaxPriceInfo taxPriceInfo;
		public String creationSiteId;
		public Boolean allowAlternateCurrency;
		public String x_poNumber;
		public List<Object> approverMessages;
		public String x_externalShippingMethodId;
		public Object orderUpdationRemarks;
		public Integer paymentGroupCount;
		public Decimal x_subtotal;
		public Decimal x_totalItemDiscountOnOrder;
		public List<Object> submissionErrorCodes;
		public Object recurringChargePriceInfo;
		public Decimal x_shippingTax;
		public Organization organization;
		public String siteId;
		public List<Object> markers;
	}
	public class cls_relationships {
		public String paymentGroupId;	//pg650061
		public Integer amount;	//924
		public String relationshipType;	//ORDERAMOUNTREMAINING
		public String id;	//r670203
	}
	public class CommerceItem {
		public Boolean gwp;
		public String deactivationDate;
		public Integer returnedQuantity;
		public String availabilityDate;
		public String billingProfileId;
		public List<Object> externalData;
		public String billingAccountId;
		public Integer preOrderQuantity;
		public String assetKey;
		public String commerceItemId;
		public CommerceItemPriceInfo priceInfo;
		public String catalogId;
		public cls_externalRecurringChargeDetails externalRecurringChargeDetails;
		public ExternalPriceDetails externalPriceDetails;
		public String x_state;
		public String actionCode;
		public String id;
		public String state;
		public String serviceId;
		public Decimal x_discountAmount;
		public cls_locationInventoryInfoMap locationInventoryInfoMap;
		public String x_skuId;
		public String x_shippedQuantity;
		public String x_overnightShipping;
		public String serviceAccountId;
		public Decimal x_discountPercentage;
		public Integer quantity;
		public Boolean pointOfNoRevision;
		public String productId;
		public String parentAssetKey;
		public String externalId;
		public String x_trackingInfo;
		public String originalCommerceItemId;
		public String rootAssetKey;
		public String transactionDate;
		public String catalogRefId;
		public Decimal x_discount;
		public String customerAccountId;
		public String recurringChargePriceInfo;
		public List<Object> lineAttributes;
		public String catalogKey;
		public String productDisplayName;
		public String siteId;
		public cls_shopperInput shopperInput;
		public String activationDate;
		public Boolean asset;
		public Integer backOrderQuantity;
	}

	public class cls_externalRecurringChargeDetails{
		
	}
	public class cls_locationInventoryInfoMap {

	}

	public class cls_shopperInput {

	}
	
	public class CommerceItemPriceInfo {
		public Boolean discounted;
		public Decimal amount;
		public Integer secondaryCurrencyShippingSurcharge;
		public Decimal rawTotalPrice;
		public Integer salePrice;
		public List<Object> orderDiscountInfos;
		public String priceListId;
		public List<Object> itemDiscountInfos;
		public Integer quantityDiscounted;
		public Boolean amountIsFinal;
		public Boolean onSale;
		public Integer shippingSurcharge;
		public Boolean discountable;
		public List<CurrentPriceDetail> currentPriceDetailsSorted;
		public String currencyCode;
		public Decimal listPrice;
	}
	
	public class CurrentPriceDetail {
		public Integer secondaryCurrencyTaxAmount;
		public Boolean discounted;
		public Decimal amount;
		public Integer quantity;
		public Integer configurationDiscountShare;
		public Boolean amountIsFinal;
		public CIRange range;
		public Decimal tax;
		public Integer orderDiscountShare;
		public Decimal detailedUnitPrice;
		public String currencyCode;
	}
	
	public class CIRange {
		public Integer lowBound;
		public Integer highBound;
		public Integer size;
	}
	
	public class ExternalPriceDetails {
		public Integer externalPriceQuantity;
		public Integer externalPrice;
	}
	
	public class RootObject {
		public List<CommerceItem> commerceItems;
	}
	

	public class ShippingGroup {
		public String shippingMethod;
		public String description;
		public String submittedDate;
		public ShippingGroupPriceInfo priceInfo;
		public Date shipOnDate;
		public Date actualShipDate;
		public cls_specialInstructions specialInstructions;
		public ShippingAddress shippingAddress;
		public List<CommerceItemRelationship> commerceItemRelationships;
		public String state;
		public String id;
		public String stateDetail;
		public String trackingNumber;
		public List<String> handlingInstructions;
		public String shippingGroupClassType;
	}
	public class cls_specialInstructions{

	}

	public class ShippingGroupPriceInfo {
		public Decimal secondaryCurrencyTaxAmount;
		public Boolean discounted;
		public Decimal shippingTax;
		public Decimal secondaryCurrencyShippingAmount;
		public Decimal amount;
		public Decimal rawShipping;
		public Boolean amountIsFinal;
		public String currencyCode;
	}

	public class ShippingAddress {
		public String country;
		public String lastName;
		public String address3;
		public String city;
		public String address2;
		public String prefix;
		public String address1;
		public String companyName;
		public String jobTitle;
		public String postalCode;
		public String county;
		public String x_externalAddressId;
		public String ownerId;
		public String suffix;
		public String firstName;
		public String phoneNumber;
		public String faxNumber;
		public String middleName;
		public String state;
		public String email;
	}

	public class CommerceItemRelationship {
		public Date availablePickupDate;
		public String inventoryLocationId;
		public Decimal amount;
		public Integer quantity;
		public Boolean pointOfNoRevision;
		public String relationshipType;
		public Integer returnedQuantity;
		public Date preferredPickupDate;
		public Range range;
		public String commerceItemExternalId;
		public String commerceItemId;
		public String state;
		public String id;
	}

	public class Range {
		public Integer lowBound;
		public Integer highBound;
		public Integer size;
	}
	

	public class cls_profile {
		public String lastName;	//Greenfield
		public String firstName;	//Jay
		public string customerContactId;
		public cls_loyaltyPrograms[] loyaltyPrograms;
		public string shippingAddress;
		public string middleName;
		public String login;	//greeney2@aol.com
		public cls_parentOrganization parentOrganization;
		public String email;	//greeney2@aol.com
	}
	public class cls_loyaltyPrograms {
	}
	public class cls_parentOrganization {
		public String name;	//149364 - Dr. Jay Greenfield
		public String externalOrganizationId;	//149364
		public String id;	//1300019
	}
	public class cls_submissionErrorMessages {
	}
	public class cls_approverIds {
	}
	public class cls_gwpMarkers {
	}
	public class PaymentProps {
		public String occsSavedCardId;
	}
	
	public class StatusProps {
		public String hostTransactionTimestamp;
		public String responseReason;
		public String responseDescription;
		public String cardType;
		public String hostTransactionId;
		public String currencyCode;
		public String occs_tx_id;
		public String responseCode;
		public String token;
	}
	
	public class AuthorizationStatus {
		public Decimal amount;
		public StatusProps statusProps;
		public Boolean transactionSuccess;
		public String errorMessage;
		public String transactionId;
	}
	
	public class BillingAddress {
		public String country;
		public String lastName;
		public String address3;
		public String city;
		public String address2;
		public String prefix;
		public String address1;
		public String companyName;
		public String jobTitle;
		public String postalCode;
		public String county;
		public String x_externalAddressId;
		public String ownerId;
		public String suffix;
		public String firstName;
		public String phoneNumber;
		public String faxNumber;
		public String middleName;
		public String state;
		public String email;
	}
	
	public class PaymentGroup {
		public String expirationYear;
		public Decimal amountAuthorized;
		public Decimal amount;
		public String gatewayName;
		public PaymentProps paymentProps;
		public String expirationMonth;
		public String submittedDate;
		public List<AuthorizationStatus> authorizationStatus;
		public String IIN;
		public String paymentGroupClassType;
		public String creditCardNumber;
		public String paymentMethod;
		public String state;
		public String id;
		public BillingAddress billingAddress;
		public List<Object> debitStatus;
		public String currencyCode;
	}
	
	public class PriceInfo {
		public Decimal secondaryCurrencyTaxAmount;
		public Boolean discounted;
		public Decimal secondaryCurrencyShippingAmount;
		public Decimal amount;
		public Decimal secondaryCurrencyTotal;
		public Decimal manualAdjustmentTotal;
		public Decimal discountAmount;
		public Decimal tax;
		public Decimal rawSubtotal;
		public Decimal total;
		public Decimal shipping;
		public Decimal primaryCurrencyTotal;
		public Boolean amountIsFinal;
		public Map<String, Decimal> orderTotalBySite;
		public String currencyCode;
	}
	
	public class TaxPriceInfo {
		public Decimal secondaryCurrencyTaxAmount;
		public Boolean discounted;
		public Decimal valueAddedTax;
		public Decimal amount;
		public Decimal countyTax;
		public Boolean isTaxIncluded;
		public Decimal miscTax;
		public Decimal districtTax;
		public Decimal stateTax;
		public Map<String, Decimal> miscTaxInfo;
		public Decimal countryTax;
		public Decimal cityTax;
		public Boolean amountIsFinal;
		public String currencyCode;
	}
	
	public class Organization {
		public String repositoryId;
		public String name;
		public Boolean active;
		public String externalOrganizationId;
		public String id;
	}
}