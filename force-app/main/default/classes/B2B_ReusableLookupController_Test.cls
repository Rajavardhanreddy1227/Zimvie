@isTest
public class B2B_ReusableLookupController_Test {
@isTest
    static void testFetchRecords() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        B2B_ReusableLookupController.SearchWrapper testInput = new B2B_ReusableLookupController.SearchWrapper();
        testInput.fieldApiName = 'Name';
        testInput.otherFieldApiName = 'Industry';
        testInput.objectApiName = 'Account';
        testInput.searchString = 'Test';
        testInput.selectedRecordId = null;
        testInput.parentFieldApiName = null;
        testInput.parentRecordId = null;
        testInput.accountId = null;


        // Call the method
      
        List<B2B_ReusableLookupController.ResultWrapper> result = B2B_ReusableLookupController.fetchRecords(testInput);
           System.assertEquals(1, result.size());
        
        // Assert the results
        
       
    }

    @isTest
    static void testFetchRecordsWithNullInput() {
        // Call the method with null input
        List<B2B_ReusableLookupController.ResultWrapper> result = B2B_ReusableLookupController.fetchRecords(null);

        // Assert the result
        System.assertEquals(null, result);
    }

    
}