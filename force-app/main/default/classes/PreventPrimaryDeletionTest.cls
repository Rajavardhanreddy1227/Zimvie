//****************************************************************************************************
//    Name: PreventPrimaryDeletionTest
//==============================================================================================
//    Author: Prateekshit Malhotra
//==============================================================================================
//    Create Date: 23-May-2012     
//==============================================================================================
//    Purpose: This is Test Class for PreventPrimaryDeletion Trigger.
//==============================================================================================
  
//******************************************************************************************************/

@isTest
private class PreventPrimaryDeletionTest{
            
            Public Static Opportunity testOpportunity;
            Public Static Competitor__c testCompetitor;
            
            Public Static void createData(){
            
            testOpportunity= new Opportunity();
            testOpportunity.Name = 'a';
            testOpportunity.CloseDate = Date.today();
            testOpportunity.StageName = 'Prospecting';
            testOpportunity.Competitor__c = 'A';
            insert testOpportunity;
            
            testCompetitor= new Competitor__c();
            testCompetitor.Competitor__c = 'AAP';
            testCompetitor.Sales_Plan__c = testOpportunity.id;
            insert testCompetitor;
            }
            
            public Static testmethod void primaryDeletion(){
            test.startTest();
            createData();
            delete testCompetitor;
            test.stopTest();
            }
            }