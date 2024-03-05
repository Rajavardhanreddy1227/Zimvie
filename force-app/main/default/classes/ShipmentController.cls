public without sharing class ShipmentController {

   @AuraEnabled(cacheable=true)
   public static List<ShipmentItem> getShipments(String orderId) {
       return [
           SELECT TrackingNumber, TrackingUrl, Product2.Name, OrderItemSummary.OrderSummaryId, Shipment.Status, Quantity
           FROM ShipmentItem
           WHERE OrderItemSummary.OrderSummary.OriginalOrderId = :orderId
       ];
   }
}