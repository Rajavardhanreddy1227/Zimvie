/*
*********************************************************
Apex Class Name    : b2BRmaCreationAsyncCallout
Created Date       : Sep 21, 2023
@description       : This  class is used for RMA creating in Oracle.
@author            : Deepak Kumar Singh
Modification Log:
Ver   Date         Author                               Modification
1.0   09-14-2023   Deepak Singh                        Initial Version
*********************************************************
*/
public class b2BRmaCreationAsyncCallout {
    @future
    public static void createRmaInOracle(string rmaId){
        list<RMA_Item__c> RMAItems=[Select Id from RMA_Item__c where RMAId__c =:rmaId];
        
    }

}