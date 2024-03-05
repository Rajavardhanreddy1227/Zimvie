public without sharing class B2BInvoiceHelper {
    
    public static Map<String, Object> processInvoicePayment(Map<String, Object> dataMap) {
        Map<String, Object> mapResponse = new Map<String, Object>();
        
        if (dataMap != null)
        {
            System.debug('dataMap in ==>'+ dataMap);
            if(dataMap.containsKey('selectedInvoices') && dataMap.containsKey('receiptAmount')) {
                System.debug('dataMap in ==>'+ dataMap.get('selectedInvoices'));
                List<Object> invObjList = (List<Object>)dataMap.get('selectedInvoices') ;
                Set<Id> invIds = new Set<Id>();
                for(Object invId : invObjList ){
                    invIds.add((String)invId);
                }
                
                List<Invoice__c> invList = new List<Invoice__c>();
                invList =[SELECT ID, Name,Related_To_Account__r.Name,Related_To_Account__r.Customer_Number__c,Related_To_Account__r.Oracle_Account_Number__c,Related_To_Account__r.CurrencyIsoCode FROM Invoice__c WHERE Id IN :invIds];
                String receiptName;
                if(invList.size() > 0){
                    receiptName = generateReceiptName(invList);
                    Decimal receiptAmount = (Decimal)dataMap.get('receiptAmount');
                    String ccHolderName;
                    Payment_Receipt__c receipt = new Payment_Receipt__c();
                    receipt.Name = receiptName;
                    receipt.Receipt_Amount__c = receiptAmount;
                    receipt.Receipt_Date__c = System.today();
                    receipt.Receipt_Status__c = 'Tokenization In Process';
                    receipt.Customer_Number__c = String.valueOf(invList[0].Related_To_Account__r.Oracle_Account_Number__c); //TODO fetch from Account
                    receipt.CurrencyIsoCode = invList[0].Related_To_Account__r.CurrencyIsoCode; //TODO fetch from Account
                    receipt.Credit_card_holder_Name__c = '';//TODO receieve from wallet
                    // receipt.Credit_Card_Number__c = 
                    insert receipt;
                    
                    //Insert Invoice Payment
                    List<B2BInvoicePayment__c> invPaymentToInsert = new List<B2BInvoicePayment__c>();
                    for(Invoice__c inv :invList){
                        B2BInvoicePayment__c invPayment = new B2BInvoicePayment__c();
                        invPayment.Payment_Receipt__c = receipt.Id;
                        invPayment.Invoice__c = inv.Id;
                        invPaymentToInsert.add(invPayment);
                    }
                    
                    if(invPaymentToInsert.size() > 0){
                        insert invPaymentToInsert;
                    }
                    
                    if(null != receipt.Id){
                         mapResponse.put('receiptId',receipt.Id);
                         mapResponse.put('isSuccess',true);
                    }
                   
                }else{
                    mapResponse.put('isSuccess',false);
                }
                
                
                
                
            }
        }
        return mapResponse;
    }
    
    public static String generateReceiptName(List<Invoice__c> invList){
        String receiptName= '';
        String receiptInitial = 'SFS';
        if(invList.size() > 1){
            receiptInitial = 'SFA';
        }
        //receiptName =  receiptInitial + invList[0].Name;
        receiptName =  invList[0].Name + receiptInitial;
        
        return receiptName;
    }
}