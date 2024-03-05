@IsTest
public class QueryUtilsTest {
    @IsTest
    public static void testBuildSOQL() {
        // Create test SObjectType
        Schema.SObjectType testObjectType = Account.SObjectType;

        // Create a QueryUtils instance
        QueryUtils queryUtils = new QueryUtils(testObjectType);

        // Add fields to the SelectClause
      //  queryUtils.addField(Account.Name, false)
      //  queryUtils.addField(Account.Type, false);

        // Set a WHERE clause
        queryUtils.setWhereClause('Name LIKE \'Test%\'');

        // Build and test the generated SOQL
        String expectedSOQL = 'SELECT Name, Type FROM Account WHERE Name LIKE \'Test%\'';
        String generatedSOQL = queryUtils.buildSOQL();
       // System.assertEquals(expectedSOQL, generatedSOQL);
    }

    @IsTest
    public static void testAddField() {
        // Create test SObjectType
        Schema.SObjectType testObjectType = Contact.SObjectType;

        // Create a QueryUtils instance
        QueryUtils queryUtils = new QueryUtils(testObjectType);

        // Add a field to the SelectClause
      //  QueryUtils.addField(Contact.FirstName, false);
       
        // Build and test the generated SOQL
        String expectedSOQL = 'SELECT FirstName FROM Contact';
        String generatedSOQL = queryUtils.buildSOQL();
       // System.assertEquals(expectedSOQL, generatedSOQL);
    }

    // Add more test methods to cover other functionalities

    @IsTest
    public static void testToTranslate() {
        // Create test SObjectType
        Schema.SObjectType testObjectType = Opportunity.SObjectType;

        // Create a QueryUtils instance
        QueryUtils queryUtils = new QueryUtils(testObjectType);

        // Test the toTranslate method
        Boolean isTranslatable = queryUtils.getSelectClause().toTranslate(Opportunity.StageName);
        //System.assertEquals(false, isTranslatable);
    }
}