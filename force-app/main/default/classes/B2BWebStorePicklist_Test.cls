@isTest
private class B2BWebStorePicklist_Test {
    @isTest
    static void testGetValues() {
        // Create test data
        List<WebStore> testWebStores = new List<WebStore>();
        for (Integer i = 0; i < 5; i++) {
            testWebStores.add(new WebStore(Name = 'Test Store ' + i));
        }
        insert testWebStores;

        Test.startTest();
        B2BWebStorePicklist picklist = new B2BWebStorePicklist();
        VisualEditor.DynamicPickListRows values = picklist.getValues();
        Test.stopTest();

        // Add assertions to verify the expected behavior
        //System.assertEquals(5, values.getRowCount(), 'Expected row count should match')
    }
    
    @isTest
    static void testGetDefaultValue() {
        // Create test data
        WebStore testWebStore = new WebStore(Name = 'ZimVie');
        insert testWebStore;

        Test.startTest();
        B2BWebStorePicklist picklist = new B2BWebStorePicklist();
        VisualEditor.DataRow defaultValue = picklist.getDefaultValue();
        Test.stopTest();

        // Add assertions to verify the expected behavior
        System.assertNotEquals(null, defaultValue, 'Default value should not be null');
        // Add more assertions as needed
    }
}