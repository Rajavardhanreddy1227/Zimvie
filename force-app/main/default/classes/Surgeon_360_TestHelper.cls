public with sharing class Surgeon_360_TestHelper {
    public static Account createAccount(String name) {
        Account acc = new Account();
        acc.FirstName = 'TestFirst' + name;
        acc.LastName = 'TestLast' + name;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Physician').getRecordTypeId();
        acc.PersonMailingCountry = 'AG';
        return acc;
    }

    public static Account createAccount(Boolean isHide) {
        Account acc = createAccount('test');
        acc.Account_Picture_Id__c = 'test';
        acc.Hide_Surgeon_Rating__c = isHide;
        return acc;
    }

    public static Contact createContact(Id accountId) {
        Contact con = [SELECt Id FROM Contact WHERE AccountId = :accountId LIMIT 1];
        con.LastName = 'TestLast';
        con.FirstName = 'TestFirst';
        con.btydev__Picture_Id__c = 'test';
        update con;
        return con;
    }

    public static User createUser() {
        Profile p = [SELECT Id FROM profile WHERE name = 'System Administrator'];
        User userAdmin = new User();
        userAdmin.Alias = 'UserA';
        userAdmin.Email = 'testUsera@testorg.com';
        userAdmin.Emailencodingkey = 'UTF-8';
        userAdmin.Lastname = 'UserA';
        userAdmin.Languagelocalekey = 'en_US';
        userAdmin.IsActive = true;
        userAdmin.Localesidkey = 'en_US';
        userAdmin.ProfileId = p.Id;
        userAdmin.Bulletin_Board__c = true;
        userAdmin.Timezonesidkey = 'America/Los_Angeles';
        userAdmin.Username = 'UserA@testorg.com';
        insert userAdmin;
        return userAdmin;
    }

    public static Product_Usage__c createZbUsage(Id accountId) {
        Product_Usage__c pu = new Product_Usage__c();
        pu.Product_Subcategory__c = 'Shoulder';
        pu.Surgeon__c = accountId;
        pu.Brand_Desc__c = 'Stems';
        pu.Market_Units__c = true;
        pu.Date__c = Date.today();
        pu.Total_Volume__c = 1;
        return pu;
    }

    public static Product_Usage__c createMarketUsage(Id accountId) {
        Product_Usage__c pu = new Product_Usage__c();
        pu.Product_Subcategory__c = 'Shoulder';
        pu.Surgeon__c = accountId;
        pu.Brand_Desc__c = 'Stems';
        pu.Market_Units__c = false;
        pu.Date__c = Date.today();
        pu.Total_Volume__c = 1;
        return pu;
    }

    public static GPL_Profile__c createGplProfile(Id accountId, Id contactId) {
        GPL_Profile__c gpl = new GPL_Profile__c();
        gpl.Account__c = accountId;
        gpl.Contact__c = contactId;
        gpl.Picture_Id__c = 'test';
        return gpl;
    }

    public static Sunshine_Payment__c createSunshinePayments(Id accountId) {
        Sunshine_Payment__c sp = new Sunshine_Payment__c();
        sp.Amount__c = 1;
        sp.Physician__c = accountId;
        return sp;
    }

    public static Payor__c createActivePayers(Id accountId) {
        Payor__c p = new Payor__c();
        p.Archived__c = false;
        p.Physician__c = accountId;
        return p;
    }

    public static Schedule__c createSurgerySchedules(Id accountId) {
        Schedule__c s = new Schedule__c();
        s.Surgeon__c = accountId;
        s.Schedule_Date__c = Date.today();
        return s;
    }

    public static Healthcare_Surgeon_Relationship__c createHealthcareFacilityRelationships(Id accountId) {
        Healthcare_Surgeon_Relationship__c hsr = new Healthcare_Surgeon_Relationship__c();
        hsr.Surgeon__c = accountId;
        return hsr;
    }

    public static Public_Engagement__c createPublicEngagement(Id accountId) {
        Public_Engagement__c pe = new Public_Engagement__c();
        pe.Date__c = Date.today();
        pe.Surgeon_del__c = accountId;
        return pe;
    }

    public static Peer_Network__c createPeerNetwork(Id contactId) {
        Peer_Network__c pn = new Peer_Network__c();
        pn.Doctor__c = contactId;
        return pn;
    }

    public static void createSurgeonSettings(Integer multiplier) {
        Surgeon360Settings__c settings = new Surgeon360Settings__c();
        settings.Name = 'Object Multipliers';
        settings.Multiplier_Activities__c = multiplier;
        settings.Multiplier_Campaigns__c = multiplier;
        settings.Multiplier_Healthcare_Facilities__c = multiplier;
        settings.Multiplier_Opportunities__c = multiplier;
        settings.Multiplier_Payors__c = multiplier;
        settings.Multiplier_Peer_Networks__c = multiplier;
        settings.Multiplier_Product_Usage_Market__c = multiplier;
        settings.Multiplier_Product_Usage_ZB__c = multiplier;
        settings.Multiplier_Public_Engagements__c = multiplier;
        settings.Multiplier_Schedules__c = multiplier;
        settings.Multiplier_Sunshine_Payments__c = multiplier;
        settings.Multiplier_Percent_Zimmer_Usage__c = multiplier;
        insert settings;
    }

    private static Surgeon360_RatingInfluence__c createRatingInfluence(String objectName, String operator) {
        Surgeon360_RatingInfluence__c ri = new Surgeon360_RatingInfluence__c();
        ri.RHS_Value__c = 1;
        ri.Range_High__c = 1;
        ri.Range_Low__c = 0;
        ri.Return_Value__c = 10;
        ri.Related_Object_Name__c = objectName;
        ri.Operator__c = operator;
        return ri;
    }

    private static Surgeon360_RatingInfluence__c createRatingInfluence(Decimal low, Decimal high, Integer ret) {
        Surgeon360_RatingInfluence__c ri = new Surgeon360_RatingInfluence__c();
        ri.RHS_Value__c = ret;
        ri.Range_High__c = high;
        ri.Range_Low__c = low;
        ri.Return_Value__c = 10;
        ri.Related_Object_Name__c = '% Zimmer Usage';
        ri.Operator__c = 'Range';
        return ri;
    }

    public static void setupRatingSettings() {
        Map<String, String> objectOperatorMap = new Map<String, String>();
        objectOperatorMap.put('Campaigns', '<');
        objectOperatorMap.put('Healthcare Facility Relationships', '>');
        objectOperatorMap.put('Opportunities', '=');
        objectOperatorMap.put('Payors', '<=');
        objectOperatorMap.put('Peer Networks', '>=');
        objectOperatorMap.put('Product Usage - Market', 'Range');
        objectOperatorMap.put('Product Usage - ZB', '=');
        objectOperatorMap.put('Public Engagements', '=');
        objectOperatorMap.put('Schedules', '=');
        objectOperatorMap.put('Sunshine Payments', '=');
        objectOperatorMap.put('Tasks', '=');

        List<Surgeon360_RatingInfluence__c> ris = new List<Surgeon360_RatingInfluence__c>();
        for (String obj : objectOperatorMap.keySet()) {
            ris.add(createRatingInfluence(obj, objectOperatorMap.get(obj)));
        }
        for (Integer i = 0; i < 4; i++) {
            ris.add(createRatingInfluence(0.25 * i, 0.25 * (i + 1), 2 * (i + 1)));
        }
        insert ris;
    }

    public static void setup(Boolean isHide) {
        Account acc = createAccount(isHide);
        insert acc;

        Contact con = createContact(acc.Id);

        insert createGplProfile(acc.Id, con.Id);
        insert createZbUsage(acc.Id);
        insert createMarketUsage(acc.Id);
        insert createSunshinePayments(acc.Id);
        insert createActivePayers(acc.Id);
        insert createSurgerySchedules(acc.Id);
        insert createHealthcareFacilityRelationships(acc.Id);
        insert createPublicEngagement(acc.Id);
        insert createPeerNetwork(con.Id);
    }
}