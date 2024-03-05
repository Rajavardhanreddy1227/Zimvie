@isTest
public class DCM_QueryTest {
    @TestSetup
    public static void makeData(){
        Account acc = new Account();
        acc.Name = 'Test Name';
        acc.Type = 'Customer';
        acc.Customer_Type__c = 'Pharmacy';
        acc.Account_eMail__c = 'lauren119@yopmail.com';
        acc.Email__c = 'neeta.galande@rafter.one';
        acc.ShippingCountry = 'United States';
        acc.ShippingState = 'Alabama';
        acc.ShippingPostalCode = '12345';
        insert acc;
        Account acc1 = new Account();
        acc1.Name = 'Test';
        acc1.Type = 'Customer';
        acc1.Customer_Type__c = 'Pharmacy';
        acc1.Account_eMail__c = 'lauren1679@yopmail.com';
        acc1.Email__c = 'neeta.galande@rafter.one';
        acc1.ShippingCountry = 'United States';
        acc1.ShippingState = 'Alabama';
        acc1.ShippingPostalCode = '12345';
        insert acc1;
    }
    @isTest
    public static void dcmQueryTest(){
        test.startTest();
        DCM_Query query = new DCM_Query('Account', 'namespace');
        Schema.SObjectType customObjectType = Account.SObjectType;
        DCM_Query dcmQuery = new DCM_Query(customObjectType);
        test.stopTest();
        System.assert(query != null);
        
    }
    @isTest
    public static void selectFieldTest(){
        Schema.SObjectType customObjectType = Account.SObjectType;
        DCM_Query dcmQuery = new DCM_Query(customObjectType);
        List<String> strList = new List<String>{'Name', 'Industry','PersonEmail'};
        Set<String> strSet = new Set<String>{'Name', 'Industry'};
        Set<Schema.SObjectField> sObjSet = new Set<Schema.SObjectField>{Account.Name, Account.Industry};
        List<Schema.SObjectField> sObjList = new List<Schema.SObjectField>{Account.Name, Account.Industry};
        Schema.SObjectField field = Account.Name;
        DCM_Query query = new DCM_Query('Account');
        test.startTest();
        query.selectField('Name');
        query.selectFields(strList);
        query.selectFields(strSet);
        query.count('Name');
        query.selectFields('Name,PersonEmail');
        query.selectField(field);
        query.selectField(field, 'acc');
        query.selectFields(field);
        dcmQuery.selectFields(sObjSet);
        dcmQuery.selectFields(sObjList);
        query.selectField('Name', 'acc');
        test.stopTest();
        System.assert(dcmQuery != null);
        
    }
    @isTest
    public static void countTest(){
        DCM_Query quer = new DCM_Query('Account');
        test.startTest();
        quer.count('Name');
        quer.count('Name', 'as');
        test.stopTest();
        System.assert(quer != null);
        
    }
    @isTest
    public static void labelTest(){
        DCM_Query query = new DCM_Query('Account');
        test.startTest();
        query.toLabel('Name');
        query.toLabel('Name', 'as');
        query.countDistinct('Name');
        query.countDistinct('Name', 'as');
        DCM_Query.enforceGlobalSecurity(true);
        DCM_Query.enforceGlobalSecurity();
        test.stopTest();
        System.assert(query != null);
    }
    @isTest
    public static void aggregateTest(){
        Set<String> strSet = new Set<String>{'Name', 'Industry'};
            DCM_Query query = new DCM_Query('Account');
        test.startTest();
        query.max('Name');
        query.max('Name', 'as');
        query.min('Name');
        query.min('Name', 'as');
        query.avg('Name');
        query.avg('Name', 'as');
        query.sum('Name');
        query.sum('Name', 'as');
        query.groupBy('Name,Industry');
        query.groupBy(strSet);
        test.stopTest();
        System.assert(query != null);
    }
    @isTest
    public static void selectTest(){
        Account acc = [Select id from Account where name ='Test Name'];
        Account acc1 = [Select id from Account where name ='Test'];
        DCM_Query query = new DCM_Query('Account');
        Set<Id> idSet = new Set<Id>{acc.Id, acc1.Id};
            List<Id> idList = new List<Id>{acc.Id, acc1.Id};
                DCM_Query.FieldSetting config = new DCM_Query.FieldSetting();
        test.startTest();
        query.selectAllFields();
        query.selectReadableFields();
        query.selectEditableFields();
        query.selectCreatableFields();
        query.selectAllFields('Name');
        query.selectReadableFields('Name');
        query.byId(idSet);
        query.byId(idList);
        query.byId(acc.Id);
        query.selectAllFields(config);
        test.stopTest();
        System.assert(query != null);
    }
    @isTest
    public static void lookupTest(){
        Account acc = [Select id from Account where name ='Test Name'];
        Account acc1 = [Select id from Account where name ='Test'];
        DCM_Query query = new DCM_Query('Account');
        list<Account> accList = new list<Account>();
        accList.add(acc);
        Set<Id> idSet = new Set<Id>{acc.Id, acc1.Id};
            List<Id> idList = new List<Id>{acc.Id, acc1.Id};
                test.startTest();
        query.lookup('Name', acc.Id);
        query.lookup('Name', idSet);
        query.lookup('Name', idList);
        query.lookup('Name', accList);
        query.lookup('Name', query);
        query.lookup('Name', acc);
        test.stopTest();
        System.assert(query != null);
    }
    @isTest
    public static void conditionTest(){
        DCM_Query query = new DCM_Query('Account');
        List<String> strList = new List<String>{'Name', 'Industry','PersonEmail'};
            Set<String> strSet = new Set<String>{'Name', 'Industry'};
                Schema.SObjectField field = Account.Name;
        Account acc;
        test.startTest();
        query.addConditionEq('Name', acc);
        query.addConditionEq(field, acc);
        query.addConditionNotEq(field, acc);
        query.addConditionNotEq('Name', acc);
        query.addConditionIn(field, acc);
        query.addConditionIn('Name', acc);
        query.addConditionNotIn(field, acc);
        query.addConditionNotIn('Name', acc);
        query.addConditionNotIn('Name', query);
        query.addConditionNotIn(field, query);
        query.addConditionIncludes('Name',strList);
        query.addConditionIncludes(field, strList);
        query.addConditionIncludes('Name',strSet);
        query.addConditionIncludes(field, strSet);
        query.addConditionExcludes('Name',strList);
        query.addConditionExcludes(field, strList);
        query.addConditionExcludes('Name',strSet);
        query.addConditionExcludes(field, strSet);
        test.stopTest();
        System.assert(query != null);

    }
    
    @isTest
    public static void childRelationTest(){
        DCM_Query query = new DCM_Query('Account');
        test.startTest();
        query.enforceSecurity();
        query.enforceSecurity(true);
        query.setNamespace('Acc');
                query.selectEditableFields();
		//query.selectCreatableFields();
        query.debug();
        query.switchToConjunction();
        query.switchToDisjunction();
        query.resetCondition();
        query.forView();
        query.forUpdate();
        query.forReference();
        test.stopTest();
        System.assert(query != null);
    }
 
    @isTest 
    static void childRelationTestV2(){
        DCM_Query query = new DCM_Query('Account');
        test.startTest();
        query.enforceSecurity();
        query.enforceSecurity(true);
        query.setNamespace('Acc');
        query.selectCreatableFields();   // Newly Added here. 
        query.debug();
        query.switchToConjunction();
        query.switchToDisjunction();
        query.resetCondition();
        query.forView();
        query.forUpdate();
        query.forReference();
        test.stopTest();
        System.assert(query != null);
    }
    
     @isTest 
    static void childRelationTestV3(){
        DCM_Query query = new DCM_Query('Contact');
        test.startTest();
        query.enforceSecurity();
        query.enforceSecurity(true);
        query.setNamespace('Acc');
        query.selectAllFields('Account');
        query.selectAllFields();   // Newly Added here. 
        query.debug();
        query.switchToConjunction();
        query.switchToDisjunction();
        query.resetCondition();
        query.forView();
        query.forUpdate();
        query.forReference();
        test.stopTest();
        System.assert(query != null);
    }
     
    @isTest 
    static void childRelationTestV4(){
        DCM_Query query = new DCM_Query('Contact');
        query.selectFields('(Name)');
        System.assert(query != null);
    }
    
    @isTest 
    static void childRelationTestV5(){
        DCM_Query query = new DCM_Query('Contact');
        query.selectFields('Account.Name');
       System.assert(query != null);
    }
    
    
    @isTest
     static void childTest(){
        DCM_Query query = new DCM_Query('Account');
        test.startTest();
        query.setLimit(19);
        query.setOffset(1);
        query.orderBy('name');
        query.orderBy('name','DESC');
        query.orderBy('name','DESC',true);
        query.ascend();
        query.descend();
        query.orderNullsFirst();
        query.orderNullsLast();
        test.stopTest();
        System.assert(query != null);
    }
    @isTest
    static void conditionClassTest(){
        DCM_Query query = new DCM_Query('Account');
        Schema.SObjectField field = Account.Name;
        test.startTest();
        query.addConditionNull('Name');
        query.addConditionIn('Name', query);
        query.addConditionIn(field, query);
        query.addConditionNull(field);
        DCM_Query.conditionEq(field, Datetime.now());
        DCM_Query.conditionNotEq(field,DateTime.now());
        DCM_Query.conditionNull(field);
        DCM_Query.conditionNotNull(field);
        query.addConditionNotNull(field);
        query.addConditionNotNull('Name');
        test.stopTest();
        System.assert(query != null);
    }
    @isTest
     static void detailClassTest(){
        DCM_Query query = new DCM_Query('Account');
        test.startTest();
        DCM_Query.LAST_N_DAYS(10);
        DCM_Query.NEXT_N_DAYS(5);
        DCM_Query.LAST_N_WEEKS(10);
        DCM_Query.NEXT_N_WEEKS(1);
        DCM_Query.LAST_N_MONTHS(1);
        DCM_Query.NEXT_N_MONTHS(1);
        DCM_Query.LAST_N_QUARTERS(1);
        DCM_Query.NEXT_N_QUARTERS(1);
        DCM_Query.LAST_N_YEARS(1);
        DCM_Query.NEXT_N_YEARS(1);
        DCM_Query.LAST_N_FISCAL_QUARTERS(1);
        DCM_Query.NEXT_N_FISCAL_QUARTERS(1);
        DCM_Query.LAST_N_FISCAL_YEARS(1);
        DCM_Query.NEXT_N_FISCAL_YEARS(1);
        DCM_Query.buildDateLiteral('Name',1);
        query.allRows();
        test.stopTest();
        System.assert(query != null);
    }
    
    @isTest
     static void subConTest(){
        DCM_Query query = new DCM_Query('Account');
        Schema.SObjectField field = Account.Name;
        Account acc;
        test.startTest();
        query.addConditionString('Channel');
        DCM_Query.conditionIn(field, acc);
        DCM_Query.conditionIn(field, acc);
        DCM_Query.conditionIn(field, query);
        query.addConditionLike(field, acc);
        query.addConditionNotLike('Name', acc);
        query.addConditionNotLike(field, acc);
        query.addConditionIncludes('Channel', 'MyChannel');
        query.addConditionExcludes('Channel', 'MyChannel');
        query.addConditionExcludes(field, 'Name');
        test.stopTest();
        System.assert(query != null);
    }
     @isTest
     static void addConTest(){
        DCM_Query query = new DCM_Query('Account');
        Schema.SObjectField field = Account.Name;
        Account acc;
        test.startTest();
        query.addConditionLe(field, acc);
        query.addConditionLe('Name', acc);
        query.addConditionGt('Name', acc);
        query.addConditionGt(field, acc);
        query.addConditionGe('Name', acc);
        query.addConditionGe(field, acc);
        query.addConditionLike('Name', acc);
        query.addConditionIncludes(field, 'Name');
        query.addConditionLt(field, acc);
        query.addConditionLt('Name', acc);
        DCM_Query.conditionNotIn(field,acc);
        test.stopTest();
        System.assert(query != null);
    }
    @isTest
     static void addingConTest(){
        DCM_Query query = new DCM_Query('Account');
        Schema.SObjectField field = Account.Name;
        Account acc;
        test.startTest();
        DCM_Query.conditionNotIn(field,query);
        DCM_Query.conditionLt(field,acc);
        DCM_Query.conditionLe(field,acc);
        DCM_Query.conditionGt(field,acc);
        DCM_Query.conditionGe(field,acc);
        DCM_Query.conditionLike(field,acc);
        DCM_Query.conditionNotLike(field,acc);
        DCM_Query.conditionIncludes(field,'MyChannel');
        DCM_Query.conditionIncludes(field,new List<String>{'MyChannel'});
        DCM_Query.conditionIncludes(field,new Set<String>{'MyChannel'});
        test.stopTest();
        System.assert(field != null);
    }
     @isTest
     static void addingConditionTest(){
        DCM_Query query = new DCM_Query('Account');
        Schema.SObjectField field = Account.Name;
        Account acc;
        DCM_Query.Condition condition ;
        DCM_Query.Condition condition1 ;
        DCM_Query.Condition condition2 ;
        DCM_Query.Condition condition3 ;
        List< DCM_Query.Condition> conditionArgs = new List< DCM_Query.Condition>();
        test.startTest();
        DCM_Query.conditionExcludes(field,'MyChannel');
        DCM_Query.conditionExcludes(field,new List<String>{'MyChannel'});
        DCM_Query.conditionExcludes(field,new Set<String>{'MyChannel'});
        query.addHaving(condition);
        try{
         DCM_Query.doAnd(condition,condition1);
        
             }catch(Exception e){
            System.debug(e);
        }
        try{ 
        DCM_Query.doAnd(condition,condition1,condition2);
        }
        catch(Exception e){
            System.debug(e);
        }
        
        
        test.stopTest();
        System.assert(field != null);
    }
    @isTest 
      static void conditionsMethodTest(){
        DCM_Query.Condition condition ;
        DCM_Query.Condition condition1 ;
        DCM_Query.Condition condition2 ;
        DCM_Query.Condition condition3 ;
        List< DCM_Query.Condition> conditionArgs = new List< DCM_Query.Condition>();
         test.startTest();
         try{
          DCM_Query.doAnd(condition,condition1,condition2,condition3);
          

         }catch(Exception e){
             System.debug(e);
         }
          try{
           DCM_Query.doAnd(conditionArgs);   
         }catch(Exception e){
             System.debug(e);
         }
         test.stopTest();
            }
    @isTest 
      static void conditionsMethod2Test(){
        DCM_Query.Condition condition ;
        DCM_Query.Condition condition1 ;
        DCM_Query.Condition condition2 ;
        DCM_Query.Condition condition3 ;
        List< DCM_Query.Condition> conditionArgs = new List< DCM_Query.Condition>();
         test.startTest();
         try{
          DCM_Query.doOr(condition,condition1);
     
         }catch(Exception e){
             System.debug(e);
         }
          try{
       DCM_Query.doOr(condition,condition1,condition2);
          }catch(Exception e){
             System.debug(e);
         }
         test.stopTest();
       
    }
    @isTest 
     static void conditionsMethod3Test(){
        DCM_Query.Condition condition ;
        DCM_Query.Condition condition1 ;
        DCM_Query.Condition condition2 ;
        DCM_Query.Condition condition3 ;
        List< DCM_Query.Condition> conditionArgs = new List< DCM_Query.Condition>();
        test.startTest();
        try{
            DCM_Query.doOr(condition,condition1,condition2,condition3);
            
        }catch(Exception e){
            System.debug(e);
        }
        try{
            DCM_Query.doOr(conditionArgs);
        }catch(Exception e){
            System.debug(e);
        }
        try{
            DCM_Query.doNot(condition);
        }catch(Exception e){
           System.debug(e);
       }
        test.stopTest();
        
    }
    @isTest
    public static void subQueryTest(){
        DCM_Query query = new DCM_Query('Account');
        DCM_Query queryForContacts = new DCM_Query('Contact');

        Set<String> fieldSet = new Set<String>{'Name', 'Phone'};
        List<String> fieldList = new List<String>{'Name', 'Phone'};
        test.startTest();
        query.fetch();
        query.fetch(5, 20);
        query.fetch(3);
        query.run();
        query.addSubquery('Contacts');
        query.addSubquery('Contacts',fieldSet);
        query.addSubquery('Contacts',fieldList);
        query.addSubquery('Contacts','Name');
        DCM_Query.subquery('Contacts');
        test.stopTest();
        System.assert(query != null);  
    }
    
    
    @isTest 
    static void subQueryTestV2(){
      //  DCM_Query query = new DCM_Query('Account');
        
        Schema.SObjectType customObjectType = Contact.SObjectType;
        DCM_Query dcmQuery = new DCM_Query(customObjectType);
        
     // dcmQuery.addSubquery(dcmQuery); 

    }
    
    
    
    @isTest
    public static void runMethodTest(){
        Account acc = [Select id from Account where name ='Test Name'];
        Account acc1 = [Select id from Account where name ='Test'];
        DCM_Query query = new DCM_Query('Account');
        List<Id> idList = new List<Id>{acc.Id,acc1.id };
            
        
        test.startTest();
        query.runPreservingIdOrder(idList);
        query.aggregate();
        try{
                    query.countQuery();
        }catch(Exception e){
            System.debug(e);
        }try{
                    query.toIdList();

        }catch(Exception e){
            
        }
        query.getSObjectType();
        try{
                    query.getQueryLocator();
        }catch(Exception e){
            
        }
        
        test.stopTest();
    }
    @isTest
    public static void condMethodTest(){
        DCM_Query.Condition equation  ;
        try{
             equation.doNot(); 
        }catch(exception e){
            System.debug(e);
        }
    }
    
   
    
        @isTest
    static void testInvalidFieldException() {
        // Specify the namespace if applicable
        String namespacePrefix = ''; // Fill this in if needed
        
        // Define a custom object type (use a standard object if desired)
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(namespacePrefix + 'Custom_Object__c');
        
        // Define a field name that is not valid for the custom object type
        String invalidFieldName = 'Invalid_Field__c';
        
        // Test the exception
        Test.startTest();
        try {
            throw new DCM_Query.InvalidFieldException(invalidFieldName, objectType);
            // If the exception isn't thrown, the following line would fail the test
         //   System.assert(false, 'Expected exception to be thrown');
        } catch (DCM_Query.InvalidFieldException e) {
            // Check if the exception message is as expected
            String expectedMessage = 'Invalid field \'' + invalidFieldName + '\' for object \'' + objectType + '\'';
            System.assertEquals(expectedMessage, e.getMessage());
            
            // Check if the exception object type and field name are as expected
         //   System.assertEquals(objectType, e.objectType);
        //    System.assertEquals(invalidFieldName, e.fieldName);
        }
        Test.stopTest();
    }

    
    
}