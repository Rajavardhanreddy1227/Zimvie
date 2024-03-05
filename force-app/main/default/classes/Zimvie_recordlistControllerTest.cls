@isTest
private class Zimvie_recordlistControllerTest {
    
    @isTest static void test_loadRecords() {
        // Create a mock Account record
        Account a = new Account(Name='Test Account');
        insert a;

        // Call loadRecords method for Account object
        Zimvie_recordlistController.DataTableResponse response = Zimvie_recordlistController.loadRecords('Account', 'Id,Name');

        // Assert the results
        System.assertNotEquals(null, response);
        System.assertNotEquals(null, response.lstDataTableData);
        System.assertEquals(1, response.lstDataTableData.size());
        System.assertNotEquals(null, response.lstDataTableColumns);
        System.assertEquals(2, response.lstDataTableColumns.size()); // Id and Name

        // You can extend this by adding more detailed assertions, verifying field labels and other details.
    }
}