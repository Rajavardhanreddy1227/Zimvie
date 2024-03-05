@isTest
public with sharing class DentalTriggersTestClass {

private static testMethod void DentalTest(){
                
                Account accountTest = new Account();
                ID recordTypeId6 = [select id from RecordType where SObjectType='Account' and Name='Distributor'].id;
    			ID User = [select id from User where Name ='Lily Rose' and IsActive = true].id;
                accountTest.Name='Test Account'; 
                accountTest.RecordTypeId=recordTypeId6;
                accountTest.BillingCountry='US';
                accountTest.BillingState='CA';
                accountTest.BillingStreet='Test Line1'+'\n'+'Mailing line2'+'\n'+'Mailing line3';
                accountTest.Distributor_Name__c='Test Distributor Name';
                accountTest.Territory_Number__c='9999';
                accountTest.OwnerId = User;
                insert accountTest;
                
                dental_Deal__c w = new dental_Deal__c();
                w.account__c = accountTest.id;
                w.Description__c = 'a';
                w.OwnerId = User;           
                insert w;
                
                
                //w.Warranty_Relationship__c = '0015000000LwRkD';     
                DN_Account_Sales_Analytics__c d = new DN_Account_Sales_Analytics__c();
                d.account__c = accountTest.id;
                d.Biomend_Biomend_Extend_YTD__c = 6;
                d.Colla_All_Products_FPY__c = 8;
                d.Colla_All_Products_PYTD__c = 5;
                d.Colla_All_Products_YTD__c = 9;
                d.Puros_Block_FPY__c = 7;
                d.Puros_Block_PYTD__c = 6;
                d.Puros_Block_YTD__c = 5;
                d.Puros_Cancellous_FPY__c =6;
                d.Puros_Cancellous_PYTD__c = 4;
                d.Puros_Cancellous_YTD__c = 5;
                d.Puros_CC_Mix_FPY__c = 5;
                d.Puros_CC_Mix_PYTD__c =7;
                d.Puros_CC_Mix_YTD__c =6;
                d.Puros_Cortical_FPY__c = 6;
                d.Biomend_Biomend_Extend_FPY__c = 5;
                d.Biomend_Biomend_Extend_PYTD__c = 6;
                d.OwnerId = User;           
                insert d;
                 try{
                    //update w;
                    dental_Deal__c a = [select id, Description__c from  dental_Deal__c where id = :w.id];
                    System.assertEquals('a',w.Description__c);
                    
                    DN_Account_Sales_Analytics__c b = [select id, Biomend_Biomend_Extend_YTD__c from  DN_Account_Sales_Analytics__c where id = :d.id];
                    System.assertEquals(6,d.Biomend_Biomend_Extend_YTD__c);
            
        } catch (System.DmlException e){
            System.debug('we caught a dml exception: ' + e.getDmlMessage(0));    
        }
    }  

}