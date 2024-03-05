@isTest
private class RuntimeTest {
    @isTest
    static void testSpeed(){
        Runtime.sleep(1000); 
        Account a = new Account();
        List<Account> alst = new List<Account>();
        Runtime.getType(new Account());
        Runtime.getTypeName(new Account());
        //Runtime.getSObjectFieldType('Name'); 
        Runtime.getListItemType(alst);
        Runtime.newListOfTheSameType(alst);
        Runtime.getRunningClass();
        Runtime.getRunningMethod();
        Runtime.getStackLocation();
        Runtime.getCaller();
        
    }
    @isTest
    static void testGetIterableItemType() {
        Set<String> stringSet = new Set<String>{'a', 'b', 'c'};
            Type mapType = Runtime.getIterableItemType(stringSet);
    }
    @isTest
    static void testGetSObjectFieldType() {
        SObjectField testField = Account.Name;
        Map<String, Type> fieldTypeMap = new Map<String, Type>{
            'xsd:string' => String.class,
                'xsd:int' => Integer.class,
                'xsd:boolean' => Boolean.class
                };
                    Type fieldType = Runtime.getSObjectFieldType(testField);
        System.assertEquals(String.class, fieldType); 
    }
    
    @isTest
    static void testNewListOfItemType() {
        Type integerType = Integer.class;
        List<Object> integerList = Runtime.newListOfItemType(integerType);
        System.assertEquals(0, integerList.size());
        Type stringType = String.class;
        List<Object> stringList = Runtime.newListOfItemType(stringType);
        System.assertEquals(0, stringList.size());
        Type customType = Runtime.class;
        List<Object> customList = Runtime.newListOfItemType(customType);
        System.assertEquals(0, customList.size());
    }
    @isTest
    static void testNewListOfItemType1() {
        // Test with Account SObjectType
        SObjectType accountType = Schema.Account.SObjectType;
        List<SObject> accountList = Runtime.newListOfItemType(accountType);
        System.assertEquals(0, accountList.size());
        SObjectType contactType = Schema.Contact.SObjectType;
        List<SObject> contactList = Runtime.newListOfItemType(contactType);   
        System.assertEquals(0, contactList.size());
        SObjectType customType = Schema.Account.SObjectType;
        List<SObject> customList = Runtime.newListOfItemType(customType);
        System.assertEquals(0, customList.size());
    }
    
    @isTest
    static void testNewListOfFieldType() {
        // Test with Account.Name field (String type)
        SObjectField nameField = Account.Name;
        List<Object> nameList = Runtime.newListOfFieldType(nameField);
        System.assertEquals(0, nameList.size());
        SObjectField emailField = Contact.Email;
        List<Object> emailList = Runtime.newListOfFieldType(emailField);
        System.assertEquals(0, emailList.size());
    }
}