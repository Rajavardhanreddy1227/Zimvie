public class TestUtilsLocal {
    
    public static Account createAccount(String name, Boolean isInsert) {
        
        Id accrecId = RecordTypeHelper.getRecordTypeId('Account','DN_ISR_ACCT');
        Account acc = new Account();
        acc.Name = name;
        acc.MDM_SAP_ID__c = '123412341234';
        acc.RecordTypeId = accrecId;
        if(isInsert) {
            insert acc;
        }
        return acc;
    }
    
    public static Account createPhysicianAccount(String FName, String LName,Boolean isInsert) {
        Account acc = new Account();
        acc.RecordTypeId = [Select Id From RecordType where sobjectType = 'Account' and Name='Physician'].Id;
        acc.FirstName = FName;
        acc.LastName = LName;
        acc.BillingState = 'AB';
        acc.PersonMailingCountry = 'US';
        acc.PersonMailingStreet = 'Test';
        acc.PersonMailingState = 'NM';
        acc.PersonMailingPostalCode = '87131';
        acc.PersonMailingCity = 'Test City';
        
        if(isInsert) {
            insert acc;
        }
        return acc;
    }
    
    public static Opportunity createOpportunity(Account acc, String name, Boolean isInsert) {
        Opportunity opp = new Opportunity();
        opp.Name = name;
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today() + 1;
        opp.StageName = 'Lead';
        
        if(isInsert) {
            insert opp;
        }
        return opp;
    }
    
    public static Territory2Model createTerritory2Model(String Name, String DeveloperName, Boolean isInsert) {
        Territory2Model t2m = new Territory2Model();
        t2m.Name = Name;
        t2m.DeveloperName = DeveloperName;
        // t2m.State = 'Active';
        
        if(isInsert) {
            insert t2m;
        }
        return t2m;
    }
    
    /*public static Territory2Type createTerritory2Type(String Name, Integer Priority, Boolean isInsert) {
Territory2Type t2t = new Territory2Type();
t2t.MasterLabel = Name;
t2t.Priority = Priority;

if(isInsert) {
insert t2t;
}
return t2t;
}*/
    
    public static Territory2 createTerritory2(String Name, String DeveloperName, Territory2Model territory2Model, Territory2Type territory2Type, Boolean isInsert) {
        Territory2 ter = new Territory2();
        ter.AccountAccessLevel = 'Read';
        ter.CaseAccessLevel = 'Read';
        ter.OpportunityAccessLevel = 'Read';
        ter.Name = Name;
        ter.DeveloperName = DeveloperName;
        ter.Territory2ModelId = territory2Model.Id;
        ter.Territory2TypeId = territory2Type.Id;
        
        if(isInsert) {
            insert ter;
        }
        return ter;
    }
    
    public static ObjectTerritory2Association createObjectTerritory2Association(Account acc, Territory2 tr, Boolean isInsert) {
        ObjectTerritory2Association o2a = new ObjectTerritory2Association();
        o2a.ObjectId = acc.Id;
        o2a.Territory2Id = tr.Id;
        o2a.AssociationCause = 'Territory2Manual';
        
        if(isInsert) {
            insert o2a;
        }
        return o2a;
    }
    
    //Added to test OpportunityReScheduling trigger - 30/01/2020 - Ayush Goyal(Appirio) 
    
    public static User createTestUser(String UName,Boolean isInsert){
        system.debug('inserting user');
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'testu', Email='testuser@testorg.com.invalid', 
                          EmailEncodingKey='UTF-8', LastName=UName, LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName=UName+'@testorg.com');
        TestUtilsLocal.createCustomSetting('AddUsersToPSQueues Trigger',true);
        if(isInsert){
            system.debug('inside if');
            insert u;
        }
        system.debug('returning');
        return u;
    }
    
    public static void createCustomSetting(String CSName,Boolean isInsert){
        Trigger_Settings__c cs = new Trigger_Settings__c();
        cs.Name = CSName;
        cs.Active__c = true;
        if(isInsert){
            insert cs;
        }
    }
    
    
    //Added by Ankit BIrla to insert Sales Rep User on 06/03/2020    
    public static User createTestSalesUser(String UName,Boolean isInsert){
        Profile p = [SELECT Id FROM Profile WHERE Name='Custom-Zimmer Sales']; 
        List<PermissionSet> lstPerSet = [SELECT Id,Name FROM PermissionSet  WHERE Name ='Ortho_Mobile_Users'];
        User opUser = new User(Alias = 'testu', Email='testuser@testorg.com.invalid', 
                               EmailEncodingKey='UTF-8', LastName=UName, LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US', ProfileId = p.Id, 
                               TimeZoneSidKey='America/Los_Angeles', UserName=UName+'@testorg.com');
        if(isInsert){            
            insert opUser;
            insert new PermissionSetAssignment(AssigneeId = opUser.id, PermissionSetId = lstPerSet[0].Id);            
            
        }        
        return opUser;
    }
    
    //Added by Ankit BIrla to insert Product2 on 13/03/2020 
    public static Product2 createProduct(){
        Product2 Prod =  new Product2();
        Prod.Name='NewProd';
        Prod.IsActive=True;
        prod.CanUseQuantitySchedule = True;
        prod.CanUseRevenueSchedule = True;
        insert Prod;
        
        return Prod;
    }
    //Added by Ankit BIrla to insert PricebookEntry on 13/03/2020 
    public static PricebookEntry createPriceBook(){
        Product2 Prod = createProduct();
        PricebookEntry stdpbe = new PricebookEntry();
        stdpbe.Product2Id=Prod.Id;
        stdpbe.IsActive=True;
        stdpbe.UnitPrice=70;
        stdpbe.Pricebook2Id = Test.getStandardPricebookId();
        stdpbe.UseStandardPrice=false;
        insert stdpbe;
        
        return stdpbe;
    }
}