/*****************************************************************************/
/* Class Trigger name: SalesHistoryOwnerUpdateAfterInsert                    */
/* Author: Arun Kumar Singh                                                  */
/* Last modified: June 2011                                                  */
/* Purpose: Used to update Owner of SalesHistory as per the Account owner    */                                          
/*****************************************************************************/
trigger SalesHistoryOwnerUpdateAfterInsert on Sales_History__c (after insert) {
/*
System.debug('Inside SalesHistoryOwnerUpdateAfterInsert Trigger');	
//List of saleshistories returned by Trigger.New
List<Sales_History__c> listSalesHistories = new List<Sales_History__c>();
 
for(Sales_History__c SalesHistory:[Select Id, Account__c,Account__r.OwnerId from Sales_History__c where Id IN: Trigger.new])
{   
    listSalesHistories.add(SalesHistory);
}

for(Sales_History__c SalesHistoryRecord:listSalesHistories)
{
	if(SalesHistoryRecord.Account__c!=null)
	{
		SalesHistoryRecord.OwnerId=SalesHistoryRecord.Account__r.OwnerId;
	}
}
System.debug('listSalesHistories Size='+listSalesHistories.size());
if(listSalesHistories.size() > 0)
{
        Database.Error err;
        Database.SaveResult[] saveresults = Database.update(listSalesHistories,false);
        for(Database.SaveResult dsr:saveresults)
        {
            if(!dsr.isSuccess())
            {
                err = dsr.getErrors()[0];
                System.debug('SalesHistoryOwnerUpdateAfterInsert Trigger'+err.getMessage());                                 
            }               
        }
listSalesHistories.clear();
}
*/
}