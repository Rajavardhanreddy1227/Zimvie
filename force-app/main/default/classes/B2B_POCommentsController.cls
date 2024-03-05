public class B2B_POCommentsController {
    @AuraEnabled
    public static void savePoCommentsOnCart(String cartId,String pocomments) {
        WebCart objCart = new WebCart(Id=cartId);
        objCart.B2B_PO_Number__c = pocomments;
        update objCart;
    }
}