import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import loading from '@salesforce/label/c.loading';
import getOrderSummary from '@salesforce/apex/OrderSummaryDetailController.getOrderSummary';
import Order from '@salesforce/label/c.Order';
import Back_to_All_Orders from '@salesforce/label/c.Back_to_All_Orders';
import Purchase_Order_Number from '@salesforce/label/c.Purchase_Order_Number';
import Order_Details from '@salesforce/label/c.Order_Details';
import Ordered_Date from '@salesforce/label/c.Ordered_Date';
import Account from '@salesforce/label/c.Account';
import Placed_By from '@salesforce/label/c.Placed_By';
import Status from '@salesforce/label/c.Status';
import checkoutCartSummary_OrderSummary from '@salesforce/label/c.checkoutCartSummary_OrderSummary';
import checkoutCartSummary_OrderSubtotal from '@salesforce/label/c.checkoutCartSummary_OrderSubtotal';
import checkoutCartSummary_DiscountAdjustments from '@salesforce/label/c.checkoutCartSummary_DiscountAdjustments';
import checkoutCartSummary_Tax from '@salesforce/label/c.checkoutCartSummary_Tax';
import checkoutCartSummary_Shipping from '@salesforce/label/c.checkoutCartSummary_Shipping';
import checkoutCartSummary_ShippingDiscount from '@salesforce/label/c.checkoutCartSummary_ShippingDiscount';
import checkoutCartSummary_ShippingTax from '@salesforce/label/c.checkoutCartSummary_ShippingTax';
import checkoutCartSummary_TissueHandlingFee from '@salesforce/label/c.checkoutCartSummary_TissueHandlingFee';
import Shipment_Details from '@salesforce/label/c.Shipment_Details';
import Shipment_Method from '@salesforce/label/c.Shipment_Method';
import Shipment from '@salesforce/label/c.Shipment';
import Tracking from '@salesforce/label/c.Tracking';
import SKULabel from '@salesforce/label/c.SKULabel';
import Item_Summary from '@salesforce/label/c.Item_Summary';
import Items from '@salesforce/label/c.Items';
import LengthLabel from '@salesforce/label/c.LengthLabel';
import DiameterLabel from '@salesforce/label/c.DiameterLabel';
import qtyLabel from '@salesforce/label/c.qtyLabel';
import item from '@salesforce/label/c.item';
import Discount from '@salesforce/label/c.Discount';
import Total from '@salesforce/label/c.Total';
import Oracle_Order from '@salesforce/label/c.Oracle_Order';
import Source from '@salesforce/label/c.Source';

export default class B2bOrderSummaryDetail extends NavigationMixin(LightningElement) {
    @api recordId;
    objOrder;
    objShipping;
    shipments;
    allOrderItems;
    baseURL;
    _isLoading = false;
    showItemSummary = false;
    tissueHandlingFee;
    labels = { loading };
    labels= {
        Order,
        Back_to_All_Orders,
        Purchase_Order_Number,
        Order_Details,
        Ordered_Date,
        Account,
        Placed_By,
        Status,
        checkoutCartSummary_OrderSummary,
        checkoutCartSummary_OrderSubtotal,
        checkoutCartSummary_DiscountAdjustments,
        checkoutCartSummary_Tax,
        checkoutCartSummary_Shipping,
        checkoutCartSummary_ShippingDiscount,
        checkoutCartSummary_ShippingTax,
        checkoutCartSummary_TissueHandlingFee,
        Shipment_Details,
        Shipment_Method,
        Shipment,
        Tracking,
        SKULabel,
        Item_Summary,
        Items,
        LengthLabel,
        DiameterLabel,
        qtyLabel,
        item,
        Discount,
        Total,
        Oracle_Order,
        Source
    }

    handleBacktoallorder() {
        this.dispatchEvent(new CustomEvent('backtoallorder', {
            detail: {}
        }));
    }

    connectedCallback() {
        this._isLoading = true;
        getOrderSummary({ orderSummaryId: this.recordId })
            .then((result) => {
                try {
                    console.log('ordersumm result>>>'+JSON.stringify(result));
                    let tempOrder = JSON.parse(JSON.stringify(result.OrderSummary));
                    tempOrder.TotalAdjDistAmountCustom = -1*(tempOrder.TotalProductAmount - tempOrder.TotalAdjustedProductAmount);
                    tempOrder.TotalDeliveryAdjDistAmtWithTax = -1*tempOrder.TotalDeliveryAdjDistAmtWithTax;
                    this.objOrder = tempOrder;
                    this.baseURL = result.BaseURL;
                    this.shipments = [];
                    this.allOrderItems = [];
                    var orderItemSummary = JSON.parse(result.OrderItemSummary).items;

                    for (let indx = 0; indx < result.Shipments.length; indx++) {
                        let tempShipment = {};
                        tempShipment.Id = result.Shipments[indx].Id;
                        tempShipment.TrackingNumber = result.Shipments[indx].TrackingNumber;
                        tempShipment.TrackingURL = result.Shipments[indx].TrackingUrl;
                        tempShipment.indxVal = indx + 1;
                        tempShipment.Status = result.Shipments[indx].Status;
                        tempShipment.ShipmentItems = [];
                        for (let shipIndx = 0; shipIndx < result.Shipments[indx].ShipmentItems.length; shipIndx++) {
                            var testShipItem = {};
                            testShipItem.Id = result.Shipments[indx].ShipmentItems[shipIndx].Id;
                            testShipItem.Product2Id = result.Shipments[indx].ShipmentItems[shipIndx].Product2Id;
                            testShipItem.Product2Name = result.Shipments[indx].ShipmentItems[shipIndx].Product2.Name;
                            testShipItem.Product2StockKeepingUnit = result.Shipments[indx].ShipmentItems[shipIndx].Product2.StockKeepingUnit;

                            for (let itemIndx = 0; itemIndx < orderItemSummary.length; itemIndx++) {
                                if (orderItemSummary[itemIndx].product.productId == testShipItem.Product2Id &&
                                    orderItemSummary[itemIndx].product.media) {
                                    testShipItem.ImageURL = orderItemSummary[itemIndx].product.media.url;
                                    break;
                                }
                            }

                            tempShipment.ShipmentItems.push(testShipItem);
                        }
                        this.shipments.push(tempShipment);
                    }
                    if (this.objOrder.OrderDeliveryGroupSummaries) {
                        let tempObjShip = {};
                        tempObjShip.Name = this.objOrder.OrderDeliveryGroupSummaries[0].DeliverToName;
                        tempObjShip.Street = this.objOrder.OrderDeliveryGroupSummaries[0].DeliverToStreet;
                        tempObjShip.City = this.objOrder.OrderDeliveryGroupSummaries[0].DeliverToCity;
                        tempObjShip.State = this.objOrder.OrderDeliveryGroupSummaries[0].DeliverToStateCode;
                        tempObjShip.PostalCode = this.objOrder.OrderDeliveryGroupSummaries[0].DeliverToPostalCode;
                        tempObjShip.Address = ((tempObjShip.Street ? (tempObjShip.Street + ', ') : '') + '' +
                            (tempObjShip.City ? (tempObjShip.City + ', ') : '') + '' +
                            (tempObjShip.State ? (tempObjShip.State + ' ') : '') + '' +
                            (tempObjShip.PostalCode ? tempObjShip.PostalCode : ''));
                        tempObjShip.Country = this.objOrder.OrderDeliveryGroupSummaries[0].DeliverToCountryCode;
                        if(this.objOrder.OrderDeliveryGroupSummaries[0].OrderDeliveryMethod){
                            tempObjShip.ShipmentMethod = this.objOrder.OrderDeliveryGroupSummaries[0].OrderDeliveryMethod.Name;
                        }
                        this.objShipping = tempObjShip;
                    }
                    for (let orderItmIndx = 0; orderItmIndx < this.objOrder.OrderItemSummaries.length; orderItmIndx++) {
                        var testOrdItem = {};
                        testOrdItem.Id = this.objOrder.OrderItemSummaries[orderItmIndx].Id;
                        testOrdItem.Product2Id = this.objOrder.OrderItemSummaries[orderItmIndx].Product2Id;
                        testOrdItem.Product2Name = this.objOrder.OrderItemSummaries[orderItmIndx].Product2.Name;
                        testOrdItem.Product2StockKeepingUnit = this.objOrder.OrderItemSummaries[orderItmIndx].Product2.StockKeepingUnit;

                        for (let itemIndx = 0; itemIndx < orderItemSummary.length; itemIndx++) {
                            if (orderItemSummary[itemIndx].product.productId == testOrdItem.Product2Id) {
                                if (orderItemSummary[itemIndx].product.media) {
                                    testOrdItem.ImageURL = orderItemSummary[itemIndx].product.media.url;
                                }
                                if (orderItemSummary[itemIndx].product.productAttributes) {
                                    for(let attIndx = 0; attIndx < orderItemSummary[itemIndx].product.productAttributes.attributes.length; attIndx++){
                                        if(orderItemSummary[itemIndx].product.productAttributes.attributes[attIndx].label == 'Length'){
                                            testOrdItem.Length = orderItemSummary[itemIndx].product.productAttributes.attributes[attIndx].value;
                                        }
                                        if(orderItemSummary[itemIndx].product.productAttributes.attributes[attIndx].label == 'Diameter'){
                                            testOrdItem.Diameter = orderItemSummary[itemIndx].product.productAttributes.attributes[attIndx].value;
                                        }
                                    }
                                }
                                break;
                            }
                        }

                        testOrdItem.Status = this.objOrder.OrderItemSummaries[orderItmIndx].Status;
                        testOrdItem.Quantity = this.objOrder.OrderItemSummaries[orderItmIndx].Quantity;
                        testOrdItem.Price = this.objOrder.OrderItemSummaries[orderItmIndx].UnitPrice;
                        testOrdItem.Discount = this.objOrder.OrderItemSummaries[orderItmIndx].TotalAdjustmentAmtWithTax;
                        testOrdItem.Total = this.objOrder.OrderItemSummaries[orderItmIndx].TotalPrice;
                        this.allOrderItems.push(testOrdItem);

                        if (testOrdItem.Product2StockKeepingUnit == 'TBHF') {
                            this.tissueHandlingFee = testOrdItem.Price;
                        }
                    }
                    console.log('RESULT==' + JSON.stringify(result));
                    this.showItemSummary = this.allOrderItems.length > 0 ? true : false;
                    if (this.tissueHandlingFee) {
                        this.objOrder.TotalAdjustedProductAmount = this.objOrder.TotalAdjustedProductAmount - this.tissueHandlingFee;
                    }
                    this._isLoading = false;
                }
                catch (error) {
                    this._isLoading = flase;
                    console.log('ERROR==' + error);
                }
            })
            .catch((error) => {
                this._isLoading = false;
                console.log('==ERROR==' + JSON.stringify(error));
            });
    }
    handleProductDetailNavigation(evt) {
        evt.preventDefault();
        const productId = evt.target.dataset.productid;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.baseURL + '/product/' + productId
            }
        });
    }
    get isLoading() {
        return this._isLoading;
    }
}