public with sharing class B2BCartSelector {
    
    private static final String CLASSNAME = 'B2BCartSelector';
    private static final String MODULE_NAME = 'B2B Cart Module';

    public static Set<String> getDefaultFields() {

        return new Set<String>{
            'Id',
            'AccountId',
            'BillingCity',
            'BillingState',
            'BillingCountry',
            'BillingCountryCode',
            'BillingStateCode',
            'GrandTotalAmount',
            'BillingAddress',
            'BillingStreet',
            'BillingPostalCode',
            'CurrencyIsoCode',
            'TotalAmount',
            'TotalProductAmount',
            '(SELECT Id,DeliverToName,DeliverToPostalCode,DeliverToState,DeliverToCountryCode,DeliverToStateCode,'
             + 'DeliverToStreet,DeliverToCountry,DeliverToCity,DeliveryMethodId FROM CartDeliveryGroups limit 1),'
             + '(SELECT Id,TotalAmount,Type,Name,UnitAdjustedPrice,Quantity,sku FROM CartItems)'
        };
    }

    public static Set<String> getCartTaxFields() {

        return new Set<String>{
            'Id'
        };
    }


    public static String getQueryFieldString() {
        List<String> queryFieldsList = new List<String>(getDefaultFields());
        return String.join(queryFieldsList, ',');
    }


    public static String getQueryCartTaxString() {
        List<String> queryFieldsList = new List<String>(getCartTaxFields());
        return String.join(queryFieldsList, ',');
    }


    public static WebCart queryCartDetails(List<String> cartIds)
    {
        List<String> statuses =new List<String>{'active' , 'checkout'};
        String query =' SELECT ' +getQueryFieldString() + ' FROM WebCart WHERE Id =: cartIds AND Status IN: statuses';
        List<WebCart> webcarts = Database.query(query);
        return webcarts.isEmpty() ? null : webcarts.get(0) ;
    }

    public static List<CartTax> queryCartTaxDetails(String cartId)
    {
        String query =' SELECT ' +getQueryCartTaxString() + ' FROM CartTax WHERE CartId =: cartId';
        return Database.query(query);
    }
}