@isTest
private class SchemaDescriptionsTest {
    @isTest
    static void testGetSObjectType() {
        SObjectType accSObjType = SchemaDescriptions.getSObjectType('Account');
        System.assertEquals(Account.SObjectType, accSObjType, 'Mismatch in SObject type for Account');
    }

    @isTest
    static void testGetSObjectDescribe() {
        DescribeSObjectResult describeResult = SchemaDescriptions.getSObjectDescribe('Account');
        System.assertEquals('Account', describeResult.getName(), 'Mismatch in Describe result for Account');
    }
    
	@isTest
    static void testGetSObjectDescribeWithSObjectType() {
        SObjectType accountSObjType = Schema.Account.SObjectType;
        DescribeSObjectResult describeResult = SchemaDescriptions.getSObjectDescribe(accountSObjType);
        System.assertEquals('Account', describeResult.getName(), 'Mismatch in Describe result for Account');
     
    }
    
    @isTest
    static void testGetFieldsMapWithSObjectType() {
        SObjectType accountSObjType = Schema.Account.SObjectType;
        SchemaDescriptions.FieldsMap fieldsResult = SchemaDescriptions.getFieldsMap(accountSObjType);
        System.assert(fieldsResult != null);
           }
    
    @isTest
    static void testGetFieldsMap() {
        SchemaDescriptions.FieldsMap fieldsMap = SchemaDescriptions.getFieldsMap('Account');
        System.assert(fieldsMap != null);
        
    }

    @isTest
    static void testGetSObjectField() {
        SObjectField nameField = SchemaDescriptions.getSObjectField('Account.Name');
        System.assertEquals(Account.Name, nameField, 'Mismatch in SObject field for Account.Name');
    }

    @isTest
    static void testGetSObjectFieldDescribe() {
        DescribeFieldResult fieldDescribeResult = SchemaDescriptions.getSObjectFieldDescribe('Account.Name');
        System.assertEquals('Name', fieldDescribeResult.getName(), 'Mismatch in field describe for Account.Name');
    }

    @isTest
    static void testExceptionHandling() {
        Boolean exceptionCaught = false;
        try {
            SObjectType invalidSObjType = SchemaDescriptions.getSObjectType('InvalidSObject');
        } catch (SchemaDescriptions.SchemaException e) {
            exceptionCaught = true;
        }
       // System.assertTrue(exceptionCaught, 'Exception should be thrown for invalid sObject');
    }


 
    @isTest
    static void testNamespacedAttributes() {
        Map<String, Object> sampleValues = new Map<String, Object> {
            'TestField' => 'TestValue',
            'myNamespace__TestFieldWithNamespace' => 'TestValueWithNamespace'
        };
      
    }
    
    @isTest
    static void testFieldsMap() {
        // To test FieldsMap, we can use the Account SObjectType's fields
        Map<String, Schema.SObjectField> accountFields = Schema.Account.SObjectType.getDescribe().fields.getMap();
        
        SchemaDescriptions.FieldsMap fieldsMap = new SchemaDescriptions.FieldsMap(accountFields);
        
        // Test get() method
        System.assertNotEquals(null, fieldsMap.get('Name'));
        
        // Test values() method
        System.assertNotEquals(null, fieldsMap.values());
    }
    
   
}