@isTest //(seeAllData = true)

private class EmailDataRetriveTest {
    static testMethod void testCaseFromEmail() {
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }
                
        Case aCase = new Case(OwnerId = testGroup.Id);
        aCase.Email_Data__c = 'Test'; //To test delete function of trigger
        insert aCase;   

        list<EmailMessage> emaillist = new list<EmailMessage>();
        for(integer i =0; i<3; i++){
            EmailMessage em = new EmailMessage();
            em.Subject = 'A new External Case Comment has been posted';
            em.TextBody = 'Test Email';
            em.ToAddress = 'Test' + string.valueOf(i) + '@test.com';
            em.CcAddress =	'Test' + string.valueOf(i+1) + '@test.com';
            em.BccAddress = 'Test' + string.valueOf(i+2) + '@test.com';
            //Status = 'New',
            em.Incoming = true;
            em.ParentId = aCase.ID;
            emaillist.add(em); 
        }
       	Test.startTest();
 			Insert emaillist;
       	Test.stoptest();
    }
}