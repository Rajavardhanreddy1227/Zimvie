@isTest
public class ItemstoApproveController_Test {
   
    public static Account acc;
    public static Opportunity newOpp1;
    public static Opportunity newOpp2;
    @testSetup static void setup() {
        
        Trigger_Settings__c cs = new Trigger_Settings__c();
        cs.Name = 'AddUsersToPSQueues Trigger';
        cs.Active__c = false;
        insert cs;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
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
        
        Business_Plan__c plan = new Business_Plan__c();
        plan.Name = 'Test Plan';
        plan.Active__c = TRUE;
        plan.Status__c = 'Active';
        plan.Year__c = 2019;
        plan.Territory_Account_Name__c = acc.Id;
        insert plan;
        
        Annual_Sales_Data__c annualSales = new Annual_Sales_Data__c();
        annualSales.Territory_Name__c = acc.Id;
        annualSales.Year__c = 2020;
        annualSales.This_Year_YTD_Sales_Thru_Month__c = 15000;
        annualSales.Y_1_Sales__c = 10000;
        annualSales.Full_Year_Target__c = 5000;
        annualSales.This_Year_YTD_Sales_Thru_Month__c = 3000;
        insert annualSales;
        
        Product_Sales_Summary__c pSummary = new Product_Sales_Summary__c();
        pSummary.Name = 'Test Knees Sales Summary';
        pSummary.Business_Plan__c = plan.Id;
        pSummary.Product_Group__c = 'Knees';
        pSummary.This_Quarter_Projection__c = 4000;
        pSummary.Pricing_Impact__c = 10;
        pSummary.Opportunities__c = 15000;
        pSummary.Risks__c = 2000;
        insert pSummary;
        
        Id ObtOppTypeId = RecordTypeHelper.getRecordTypeId('Opportunity','Bone_Healing');
        
        newOpp1 = new Opportunity();
        newOpp1.Name = 'Test Opp';
        newOpp1.Amount = 5000;
        newOpp1.AccountId = acc.Id;
        newOpp1.StageName = 'Target';
        newOpp1.CloseDate = date.today().addDays(30);
     //   newOpp1.RecordTypeId = '012C0000000QdBR';
        newOpp1.RecordTypeId = ObtOppTypeId;
        newOpp1.Surgeon_Name__c = acc.Id;
        newOpp1.At_Risk__c = TRUE;
        newOpp1.BP_Target__c = TRUE;
      //  newOpp1.Territory_Name__c = 'APEX SURGICAL(FOX-GATTEN)';
        newOpp1.Product_Sales_Summary__c = pSummary.Id;  //ref Product_Sales_Summary__c
        insert newOpp1;
        
        Market_Segmentation__c mkt = new Market_Segmentation__c();
        mkt.Zimmer_Biomet_Procedures__c = 5;
        mkt.Market_Procedures__c = 5;
        mkt.Surgeon_Name__c = acc.Id;
        mkt.Product_Group__c = 'Knees';
        mkt.Segementation__c = 'Gold';
        insert mkt;
        
    }
    
    static testMethod void validate_getMktData() {
        
        test.startTest();
        
        Business_Plan__c plan1 = [select Id,Name,Territory_Account_Name__r.RVP__r.Email from Business_Plan__c where name='Test Plan'];
        system.debug('Business_Plan__c :'+plan1.Territory_Account_Name__r.RVP__r.Email );
        if([select count() from ProcessInstance where targetobjectid=:plan1.id] < 1)
        {          
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Pending');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(plan1.Id);
            req.setSubmitterId(UserInfo.getUserId());
            
            //Submit the approval request
            Approval.ProcessResult result = Approval.process(req);      
            system.debug('result :'+result );
        }
        
        /*
        // Create an approval for the Business Plan and submit
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
        req.setComments('Submitting request for approval.');
        req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req.setObjectId(plan1.Id);
        
        Approval.ProcessResult resu = Approval.process(req);
        
        // Verify the result
        System.assert(resu.isSuccess());
        
        ProcessInstance proc = new ProcessInstance();
        proc.LastActorId = userinfo.getuserid();
        proc.TargetObjectId = plan1.id;//Business_Plan record id
        insert proc;
        
        ProcessInstanceWorkitem pworkItem = new ProcessInstanceWorkitem();
        pworkItem.ActorId = userinfo.getuserId();
        pworkItem.OriginalActorId = userinfo.getuserId();
        pworkItem.ProcessInstanceId = proc.id;
        insert pworkItem;
        
        System.assertEquals('Pending', resu.getInstanceStatus(),'Instance Status'+resu.getInstanceStatus());
        system.debug('status for approval:'+resu.getInstanceStatus());
        List<Id> newWorkItemIds = resu.getNewWorkitemIds();
        system.debug('newWorkItemIds :'+newWorkItemIds );
		*/
        user u = [SELECT id,name,FirstName from user where Name ='Lily Rose' and IsActive = true]; 
       
       	System.runAs(u) {
            ItemstoApproveController approveItem = new ItemstoApproveController();         
            ItemstoApproveController.ApproveRejectnavigation();
            ItemstoApproveController.REASSIGNnavigation();        
        }  
        test.stopTest();
        
    } 
    
}