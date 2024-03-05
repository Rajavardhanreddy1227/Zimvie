public without sharing class listOfRecordsToUpdateController {
        @AuraEnabled(cacheable=true)
        public static String loadRecords(String objectApiName, String fieldsName,String accid)
        {
            final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
            try {
                System.debug('accid>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ' +accid);
                if(accid == null){
                    accid = '0018L00000GssWnQAJ';
                }//testing
                String query = 'SELECT '+fieldsName+' FROM '+objectApiName + ' where Related_To_Account__c =\''+accid+'\'';
                System.debug('query>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ' +query);
                Map<Id,SObject> lstDataTableData = new Map<Id,SObject>(Database.query(query));
          		
                Map<Id,Boolean> invIdVsIsReceiptIntiatedMap = new Map<Id,Boolean>();
                Set<Id> invId = new Set<Id>();
                for(B2BInvoicePayment__c invPayment :[SELECT ID,Payment_Receipt__c,Invoice__c,Payment_Receipt__r.Receipt_Status__c FROM B2BInvoicePayment__c WHERE Invoice__c IN :lstDataTableData.keyset()]){
                    if(!invIdVsIsReceiptIntiatedMap.containsKey(invPayment.Invoice__c) && invPayment.Payment_Receipt__c != null && invPayment.Payment_Receipt__r.Receipt_Status__c != null){
                        if(invPayment.Payment_Receipt__r.Receipt_Status__c == 'Initiated'){
                            invIdVsIsReceiptIntiatedMap.put(invPayment.Invoice__c, true);
                        }
                    }
                }
                
                List<InvoiceWrapper> invWrapperList = new List<InvoiceWrapper>();
                for(Sobject inv : lstDataTableData.values()){
                    InvoiceWrapper invWrap = new InvoiceWrapper();
                    invWrap.invId = inv.Id;
                    invWrap.invoice = inv;
                    Boolean isReceiptInitiated = false;
                    if(invIdVsIsReceiptIntiatedMap.containsKey(inv.Id) && invIdVsIsReceiptIntiatedMap.get(inv.Id) != null){
                        isReceiptInitiated = true;
                    }
                    invWrap.isReceiptInitiated = isReceiptInitiated ;
                    invWrapperList.add(invWrap);
                }
                
                System.debug('invWrapperList----- '+ JSON.serialize(invWrapperList));
                return JSON.serialize(invWrapperList);
            }
            catch(exception e){
                logger.error(e);
            }
            finally{
                logger.flush();
            }
            return null;
        }
    
     @AuraEnabled
        public static String loadUserRecords(String objectApiName, String fieldsName,String accid)
        {
            final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
            try {
                System.debug('accid>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ' +accid);
                String query = 'SELECT '+fieldsName+' FROM '+objectApiName + ' where AccountId =\''+accid+'\'';
                System.debug('query>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ' +query);
                List<SObject> lstDataTableData = Database.query(query);
          
                return JSON.serialize(lstDataTableData);
            }
            catch(exception e){
                logger.error(e);
            }
            finally{
                logger.flush();
            }
            return null;
        }
       
    
     @AuraEnabled
    public static  Map<String,Object> processPayment(Map<String,Object> dataMap){
       
        Map<String,Object> mapResponseParams = new Map<String,Object>();
        try {
            mapResponseParams = B2BInvoiceHelper.processInvoicePayment(dataMap);
        } catch (Exception ex) {
            mapResponseParams.put('isSuccess', false);
        }
        return mapResponseParams;
    }

    @AuraEnabled
        public static InvoiceDetailWrapper getInvoiceDetailRecord (String invoiceName){
            try {
                InvoiceDetailWrapper invoiceDetails = new InvoiceDetailWrapper();
                Invoice__c invoice = [Select id,Name,PO_Number__c,Due_Date__c,Total_Amount__c,Invoice_Date__c,Order__c,Order__r.OrderedDate,
                Order__r.OrderNumber,Related_To_Account__c,Terms__c,Related_To_Account__r.ShippingAddress,Related_To_Account__r.BillingAddress,Related_To_Account__r.Customer_Number__c,
                Related_To_Account__r.Payment_Terms__c from Invoice__c where Name =:invoiceName];

                if(invoice != null){
                    List<Invoice_line__c> invoiveLines = [Select id,Name,Product__c,Product__r.Name, Product__r.StockKeepingUnit, UnitPrice__c,LineAmount__c,
                    TaxAmount__c,Quantity__c from Invoice_line__c where Invoice__c = :invoice.id];
                    System.debug('here invoice line>>'+invoiveLines);
                    if(!invoiveLines.isEmpty()){
                        
                        List<InvoiceLineWrapper> invoicelines = new List<InvoiceLineWrapper>();
                        for(Invoice_line__c line : invoiveLines){
                            InvoiceLineWrapper invoiceline = new InvoiceLineWrapper();
                            invoiceline.id = line.id;
                            invoiceline.name = line.Name;
                            invoiceline.quantity = line.Quantity__c;
                            invoiceline.productid = line.Product__c;
                            invoiceline.productSKU = line.Product__r.StockKeepingUnit;
                            invoiceline.productName = line.Product__r.Name;
                            invoiceline.unitPrice = line.UnitPrice__c;
                            invoiceline.lineAmount = line.LineAmount__c;
                            invoiceline.taxAmount = line.TaxAmount__c;
                            invoicelines.add(invoiceline);
                        }
                        invoiceDetails.invoiceLines = invoicelines;
                    }
                    invoiceDetails.id = invoice.id;
                    invoiceDetails.invoiceNumber = invoice.Name;
                    invoiceDetails.invoiceDate = invoice.Invoice_Date__c;
                    invoiceDetails.orderNumber = invoice.Order__r.OrderNumber;
                    invoiceDetails.orderDate = invoice.Order__r.OrderedDate;
                    invoiceDetails.customerPONumber = invoice.PO_Number__c;
                    invoiceDetails.customerNumber=invoice.Related_To_Account__r.Customer_Number__c;
                    invoiceDetails.dueDate = invoice.Due_Date__c;
                    invoiceDetails.totalAmount = invoice.Total_Amount__c;
                    invoiceDetails.shippingAddress = invoice.Related_To_Account__r.ShippingAddress;
                    invoiceDetails.billingAddress = invoice.Related_To_Account__r.BillingAddress;
                    invoiceDetails.paymentTerms = invoice.Terms__c;
                }
                System.debug('invoice details>>'+invoiceDetails);
                return invoiceDetails;
            
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
    }

    public class InvoiceDetailWrapper {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String invoiceNumber {get;set;}
        @AuraEnabled
        public Date invoiceDate {get;set;}
        @AuraEnabled
        public String orderNumber {get;set;}
        @AuraEnabled
        public datetime orderDate{get;set;}
        @AuraEnabled
        public String deliveryNumber{get;set;}
        @AuraEnabled
        public String customerNumber{get;set;}
        @AuraEnabled
        public String customerPONumber{get;set;}
        @AuraEnabled
        public Decimal totalAmount{get;set;}
        @AuraEnabled
        public Date dueDate{get;set;}
        @AuraEnabled
        public String paymentTerms{get;set;}
        @AuraEnabled
        public Address shippingAddress{get;set;}
        @AuraEnabled
        public Address billingAddress{get;set;}
        @AuraEnabled
        public List<InvoiceLineWrapper> invoiceLines{get;set;}
           
    }

    public class InvoiceLineWrapper {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public Decimal quantity {get;set;}
        @AuraEnabled
        public String productid {get;set;}
        @AuraEnabled
        public String productSKU {get;set;}
        @AuraEnabled
        public String productName {get;set;}
        @AuraEnabled
        public Decimal unitPrice {get;set;}
        @AuraEnabled
        public Decimal lineAmount {get;set;}
        @AuraEnabled
        public Decimal taxAmount {get;set;}

    }

    public class InvoiceWrapper {
       		 @AuraEnabled
            public Id invId {get;set;}
            @AuraEnabled
            public SObject invoice {get;set;}
            @AuraEnabled
            public Boolean isReceiptInitiated {get;set;}     
        }
       /*public class DataTableColumns {
            @AuraEnabled
            public String label {get;set;}
            @AuraEnabled       
            public String fieldName {get;set;}
           
            public DataTableColumns(String label, String fieldName)
            {
                this.label     = label;
                this.fieldName = fieldName;    
            }
        }
        
        public class DataTableResponse {
            @AuraEnabled
            public List<DataTableColumns> lstDataTableColumns {get;set;}
            @AuraEnabled
            public List<sObject> lstDataTableData {get;set;}     
        }

        public static Map<String,String> getMyAPINameMap(String objectApiName, List<String> fieldApiNames) {
        	Map<String,String> fieldAPILabelMap = new Map<String,String>();    
        	SObjectType type = Schema.getGlobalDescribe().get(objectApiName);
        	Map<String,Schema.SObjectField> mfields = type.getDescribe().fields.getMap();	
        	for(String strField : fieldApiNames)
        	{
            	fieldAPILabelMap.put(strField,mfields.get(strField).getDescribe().getlabel()); 
        	}
        	return fieldAPILabelMap;   
        }*/

}