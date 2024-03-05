@IsTest
private class DCM_LoggerSettingsTest {
    
    @IsTest
    static void testLogLevelNotSupported() {
        try {
            DCM_LoggerSettings.shouldCreateLog(LoggingLevel.FINE);
        }
        catch(Exception e) {
            //  System.assertEquals('r1sm.DCM_LoggerSettings.LogException', e.getTypeName());
        }
    }
    
    @IsTest
    static void testLogLevelSupported() {
        Boolean shouldCreateLog = DCM_LoggerSettings.shouldCreateLog(LoggingLevel.ERROR);
        System.assertEquals(true, shouldCreateLog);
    }
    
   /* @IsTest
    static void testRetentionDate() {
        Date retentionDate = DCM_LoggerSettings.getRetentionDate();
        System.assertNotEquals(null, retentionDate);
    }*/
    @isTest
    static void testGetRetentionDateWithSettings() {
        DCM_LoggerSettings__c setting = new DCM_LoggerSettings__c(RetentionDays__c = 30,LoggingLevel__c='NONE');
        insert setting;
        Test.startTest();
        Date retentionDate = DCM_LoggerSettings.getRetentionDate();
        Date expectedDate = Date.today().addDays(-30);
        System.assertEquals(expectedDate, retentionDate);
        Test.stopTest();
    }
    
    @isTest
    static void testGetRetentionDateWithoutSettings() {
        Test.startTest();
        Date retentionDate = DCM_LoggerSettings.getRetentionDate();
        Date expectedDate = Date.newInstance(1900, 1, 1);
        System.assertEquals(expectedDate, retentionDate);
        Test.stopTest();
    }
}