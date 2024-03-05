@isTest
public class ItemsToApp_RefinemntAVPController_Test {
    
    public static Account acc;
    
    @testSetup static void setup() {
        
        Trigger_Settings__c cs = new Trigger_Settings__c();
        cs.Name = 'AddUsersToPSQueues Trigger';
        cs.Active__c = false;
        insert cs;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' limit 1]; 
        
        user u = new User(Alias = 'stand', Email='AVPuser@testorg.com', 
                          EmailEncodingKey='UTF-8',FirstName='Gary', LastName='Campbell', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='AVPuser@testorg.com');
        insert u;
        
        Id personAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Physician');
        
        acc = new Account();
      //  acc.RecordTypeId = '012800000002C4gAAE';//Physician
        acc.RecordTypeId = personAccountTypeId;
        acc.FirstName = 'Test';
        acc.LastName = 'Acc';
        acc.Salutation = 'Dr.';
        acc.PersonMailingStreet = 'Suite 200,1501 Maple Avenue';
        acc.PersonMailingCity = 'Richmond';
        acc.PersonMailingCountry = 'US';
        acc.PersonMailingPostalCode = '23226';
        acc.PersonMailingState = 'VA';
        acc.RVP__c = u.Id;
        insert acc;
        
        Id ObtOppTypeId = RecordTypeHelper.getRecordTypeId('Opportunity','Bone_Healing');        
        
        system.debug('check my recid:' + ObtOppTypeId);
        
        Opportunity newOpp1 = new Opportunity();
        newOpp1.Name = 'Test Opp';
        newOpp1.Amount = 5000;
        newOpp1.AccountId = acc.Id;
        newOpp1.StageName = 'Target';
        newOpp1.CloseDate = date.today().addDays(30);
        newOpp1.RecordTypeId = ObtOppTypeId;
        newOpp1.Surgeon_Name__c = acc.Id;
        newOpp1.At_Risk__c = TRUE;
        newOpp1.BP_Target__c = TRUE;
    //    newOpp1.Territory_Name__c = 'ZB APEX Surgical';
        //newOpp1.Product_Sales_Summary__c = pSummary.Id;  //ref Product_Sales_Summary__c
        insert newOpp1;
        
        Territory_Name__c territoryRef = new Territory_Name__c();
        territoryRef.Name = 'APEX SURGICAL(FOX-GATTEN)';
        territoryRef.Territory_Account__c = acc.Id;
        territoryRef.Status__c = 'Round 1';
        territoryRef.Round_1_Due_Date__c = date.today().addDays(5);
        insert territoryRef;
        
        Target_Refinement__c refQuestion = new Target_Refinement__c();
        refQuestion.Territory_Type__c = 'Direct';
        refQuestion.Question_Type__c = 'Target Changes';
        refQuestion.IsActive__c = True;
        refQuestion.Product_Group__c = 'HIPS';
        refQuestion.Territory_Master__c = territoryRef.Id;
        insert refQuestion;
        
        Target_Refinement__c refQuestion1 = new Target_Refinement__c();
        refQuestion1.Territory_Type__c = 'Direct';
        refQuestion1.Question_Type__c = 'Target Changes';
        refQuestion1.IsActive__c = True;
        refQuestion1.Product_Group__c = 'KNEES';
        refQuestion1.Territory_Master__c = territoryRef.Id;
        insert refQuestion1;
        
        Target_Refinement__c refQuestion2 = new Target_Refinement__c();
        refQuestion2.Territory_Type__c = 'Direct';
        refQuestion2.Question_Type__c = 'Target Changes';
        refQuestion2.IsActive__c = True;
        refQuestion2.Product_Group__c = 'FOOT & ANKLE';
        refQuestion2.Territory_Master__c = territoryRef.Id;
        insert refQuestion2;
        
    }
    
    static testMethod void validate_ItemsToApprove() {
        
        test.startTest();
        
        Account acct = [select Id, Name,RVP__c from Account where FirstName=:'Test'];
        
        Territory_Name__c territory = [select Id,Name,Foot_and_Ankle_Total_Refinement__c,Hips_Total_Refinement__c,Knees_Total_Refinement__c,
                                       Status__c,Territory_Account__c,Territory_Account__r.RVP__r.Email from Territory_Name__c 
                                       where Territory_Account__c =: acct.Id];
        
        system.debug('territory :'+territory.Territory_Account__r.RVP__r.Email);
        
        user u = [SELECT id,name,FirstName from user where Name ='Lily Rose' and IsActive = true]; 
        system.debug('---runAs-UId---'+u.FirstName);
        
        if([select count() from ProcessInstance where targetobjectid=:territory.id] < 1)
        {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Pending');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(territory.Id);
            req.setSubmitterId(UserInfo.getUserId());
            
            //Submit the approval request
            Approval.ProcessResult result = Approval.process(req);      
            system.debug('result :'+result );
        }
        
        System.runAs(u) {
            ApexPages.StandardController sc = new ApexPages.StandardController(territory);
            
            ItemsToApprove_RefinementAVPController approveItem = new ItemsToApprove_RefinementAVPController(sc);

            ItemsToApprove_RefinementAVPController approveItem1 = new ItemsToApprove_RefinementAVPController(); 
            ItemsToApprove_RefinementAVPController.ApproveRejectnavigation();
            ItemsToApprove_RefinementAVPController.REASSIGNnavigation();        
        }  
        
        test.stopTest();
        
    }
    
}