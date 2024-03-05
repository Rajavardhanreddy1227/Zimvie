@isTest
public with sharing class MigrationMethodsTest {
    @TestSetup
    static void makeData() {
        Account physician = MigrationDataFactory.createPhysician();        
        GPL_Profile__c profile = MigrationDataFactory.createProfile(physician);
        Attachment photo = MigrationDataFactory.createPhoto(profile);
        MigrationDataFactory.createLocationWithStreetNameAndType(profile,'TEST 123 testing','Practice');
        MigrationDataFactory.createLocationWithStreetNameAndType(profile,'another \n456 different','Hospital');
        MigrationDataFactory.createLocationWithStreetNameAndType(profile,'newtest 163 new','Practice');
        Account healthcare = MigrationDataFactory.createHealthcareWithStreetName('test 123 testing');
        MigrationDataFactory.createRelationship(physician,healthcare);
        healthcare = MigrationDataFactory.createHealthcareWithStreetName('dif 199 street');
        MigrationDataFactory.createRelationship(physician,healthcare);  
        healthcare = MigrationDataFactory.createHealthcareWithStreetName('another 456 Different');
        MigrationDataFactory.createRelationship(physician,healthcare);  
        healthcare = MigrationDataFactory.createHealthcareWithStreetName('NA');
        MigrationDataFactory.createRelationship(physician,healthcare);  
        healthcare = MigrationDataFactory.createHealthcareWithStreetName('88 really long text that does not match with any location');
        MigrationDataFactory.createRelationship(physician,healthcare);  
        
        
        physician = MigrationDataFactory.createPhysician();        
        GPL_Profile__c profileWithoutLocations = MigrationDataFactory.createProfile(physician);
        healthcare = MigrationDataFactory.createHealthcareWithStreetName('test 678 testing');
        MigrationDataFactory.createRelationship(physician,healthcare);
    }
    
    @isTest
    public static void testPhotosMigration() {
        Test.startTest();
        MigrationMethods.migratePhotos();
        Test.stopTest();
        Account physician = [SELECT btydev__Picture_Id__pc FROM ACCOUNT LIMIT 1];
        System.assert(String.isNotBlank(physician.btydev__Picture_Id__pc));
    }
    
    @isTest
    public static void testProfilesMigration() {
        Test.startTest();
        MigrationMethods.migrateProfiles();
        Test.stopTest();
        Account physician = [SELECT PreferredFirstName__c,Physicians_Locator__pc,Procedures__c FROM ACCOUNT LIMIT 1];
        System.assert(String.isNotBlank(physician.PreferredFirstName__c));
        System.assert(physician.Physicians_Locator__pc);
        System.assert(String.isNotBlank(physician.Procedures__c));
    }
    
    @isTest
    public static void testLocationsMigration() {
        Test.startTest();
        MigrationMethods.migrateLocations();
        Test.stopTest();
        Healthcare_Surgeon_Relationship__c relationship = [SELECT Location_Type__c FROM Healthcare_Surgeon_Relationship__c WHERE Healthcare_Facility__r.ShippingStreet='another 456 Different' LIMIT 1];
        System.assert(relationship.Location_Type__c=='Hospital');
    }
    
    @isTest
    public static void testPostLocationMigration() {
        Test.startTest();
        MigrationMethods.migratePostLocations();
        Test.stopTest();
    }
    
    @isTest
    public static void testGetFirstNumberInString() {
        Test.startTest();
        System.assert(MigrationMethods.getFirstNumberInString('test 123').equals('123'));
        System.assert(MigrationMethods.getFirstNumberInString('test 456 test').equals('456'));
        System.assert(MigrationMethods.getFirstNumberInString('789 test').equals('789'));
        System.assert(MigrationMethods.getFirstNumberInString('test test').equals('test test'));
        Test.stopTest();
    }
    
}