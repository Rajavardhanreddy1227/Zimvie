@isTest
public class MassAttachmentsController_Test {
    
    public static Account acc;
    public static Contact con1;
    public static Contact con2;
    
    @testSetup static void setup() {
        
        Id DisAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Distributor');
        
        acc = new Account();
        acc.RecordTypeId = DisAccountTypeId;
        acc.Name = 'Test Account';
        insert acc;
        
        Id SalesContactTypeId = RecordTypeHelper.getRecordTypeId('Contact','Sales_Contact');
        
        con1 = new contact();
        con1.FirstName = 'Test';
        con1.LastName = 'Contact1';
        con1.RecordTypeId = SalesContactTypeId;
        con1.AccountId= acc.Id;
        con1.Hire_Date__c = date.today().addDays(-60);
        insert con1;
        
        con2 = new contact();
        con2.FirstName = 'Test';
        con2.LastName = 'Contact2';
        con2.RecordTypeId = SalesContactTypeId;
        con2.AccountId= acc.Id;
        con1.Hire_Date__c = date.today().addDays(-90);
        insert con2;
    }
    
    static testMethod void validateMassAttachment() {
        
        test.startTest();
        
        string recordIds = '';
        list<string> conIds = new list<string>();
        Account acct = [select Id,Name from Account where Name=:'Test Account'];
        for(Contact cont : [select Id from contact where AccountId=:acct.Id])
            {
                conIds.add(cont.Id);
                
                if(recordIds == ''){
                    recordIds = cont.Id;
                }
                else{
                    recordIds = recordIds +','+cont.Id;
                }
            }
        
        Attachment att = new Attachment();
        att.Name = 'Test';
        att.Body = EncodingUtil.base64Decode('Testing');
        att.ParentId = conIds[0];
        att.ContentType = 'File';
        //insert att;
        
        Attachment att1 = new Attachment();
        att1.Name = 'Test';
        att1.Body = EncodingUtil.base64Decode('Testing');
        att1.ParentId = conIds[1];
        att1.ContentType = 'File';
        //insert att1;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        list<ContentDocument> documents = [select Id, Title, LatestPublishedVersionId from ContentDocument];
         
        list<ContentDocumentLink> insertContentDocLink = new list<ContentDocumentLink>();
         
        //create ContentDocumentLink  record
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = conIds[0];
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insertContentDocLink.add(cdl);
        
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = conIds[1];
        cdl1.ContentDocumentId = documents[0].Id;
        cdl1.shareType = 'V';
        insertContentDocLink.add(cdl1);
        
        insert insertContentDocLink;
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(recordIds)); 

        MassAttachmentsController massAttach = new MassAttachmentsController();
        massAttach.file =Blob.valueOf('Test Content') ;
        massAttach.fileName='Test' ;
        massAttach.upload();

       
        // Test INSERT
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
        List<ContentDocument> newdocuments = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        system.assertEquals(newdocuments.size(), 2);

        test.stopTest();
        
    }
    
}