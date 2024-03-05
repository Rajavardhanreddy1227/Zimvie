/*********************************************************************************
* @author         Madalina Chirita (Deloitte Digital)
* @description    Apex Test class for Apex Controller EMEA_AccountPrintableViewController (US-0283)
* @date	          2021-10-12
**********************************************************************************/
@IsTest
private class EMEA_AccountPrintableViewTest {

    @TestSetup
	static void dataCreation() {

        /* Create Account */
        RecordType accountRT = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name = 'EMEA Non SAP Account' LIMIT 1];
		Account a = new Account(Name = 'TestAccount', RecordType=accountRT);
      	insert a;

        /* Create Contact for Account */
        RecordType contactRT = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name = 'EMEA-Medical Contact' LIMIT 1];
		Contact c = new Contact(LastName = 'Test Contact', AccountId = a.Id, EMEA_Function__c = 'Chief Surgeon', RecordType=contactRT);
        insert c;

       /* Create Account Plan for Account */
        EMEA_Account_Plan__c accPlan= new EMEA_Account_Plan__c(EMEA_Account_Plan_Name__c='Test APL', EMEA_Business_Unit__c='CMF',
                                                               EMEA_End_Date__c= Date.newInstance(2021, 10, 27),
                                                               EMEA_Start_Date__c=Date.newInstance(2021, 10, 17),
                                                               EMEA_Status__c='On track', EMEA_Account__c=a.Id);

        /* Create Account Segmentation for Account */
        List<EMEA_Account_Segmentation__c> segmentationList = new List<EMEA_Account_Segmentation__c>();
        for (Integer i = 0; i < 5; i++) {
            EMEA_Account_Segmentation__c aSegmn = new EMEA_Account_Segmentation__c(EMEA_Business_Unit__c='Recon',
                                                                            	 EMEA_Avalanche_Segment__c='Bronze', EMEA_Account__c= a.Id);
            segmentationList.add(aSegmn);
        }
        insert segmentationList;

        /* Create Competitor Analysis */
        EMEA_Competitor_Product__c newProduct = new   EMEA_Competitor_Product__c(Name='Test Product', EMEA_Competitor__c='AESCULAP',
                                                                                 EMEA_Segment__c='Hips', 	EMEA_Sub_Segment__c='Cups');
        insert newProduct;
        List<EMEA_Competitor_Analysis__c> competitorList = new List<EMEA_Competitor_Analysis__c>();
        for (Integer i = 0; i < 5; i++) {
           EMEA_Competitor_Analysis__c competitor = new EMEA_Competitor_Analysis__c(EMEA_Surgeries_per_Year__c=100,
                                                                                    EMEA_Product__c= newProduct.Id,EMEA_Description__c='--',
                                                                                    EMEA_Account__c= a.Id);
            competitorList.add(competitor);
        }
        insert competitorList;

        /* Create Partner Accounts */
        Account partnerToBeAccount = new Account(Name = 'TestAccountPartner', RecordType=accountRT);
      	insert partnerToBeAccount;
        Partner partner = new Partner(AccountToId = partnerToBeAccount.Id, Role ='Member - Hospital', AccountFromId =a.Id );
        insert partner;
     }

    @IsTest
    static void testGetAccount(){

        Test.startTest();
        Account al = [SELECT Name FROM Account WHERE Name LIKE '%Test%' LIMIT 1];
        PageReference testPage = Page.EMEA_AccountPrintableView;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(al.Id));
        Test.setCurrentPage(testPage);
        ApexPages.StandardController sc = new  ApexPages.StandardController(al);
        EMEA_AccountPrintableViewController ext = new EMEA_AccountPrintableViewController(sc);
        Account a = ext.getAccountInfo();
        System.assertEquals('TestAccount', al.Name);
        Test.stopTest();
    }

    @IsTest
    static void testGetContacts(){

        Test.startTest();
        Account al = [SELECT Name FROM Account WHERE Name LIKE '%Test%' LIMIT 1];
        PageReference testPage = Page.EMEA_AccountPrintableView;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(al.Id));
        Test.setCurrentPage(testPage);
        ApexPages.StandardController sc = new  ApexPages.StandardController(al);
        EMEA_AccountPrintableViewController ext = new EMEA_AccountPrintableViewController(sc);
        System.assertEquals('TestAccount', al.Name);
        List<Contact> ct = ext.getContacts();
        System.assertEquals('Test Contact', ct[0].Name);
        Test.stopTest();
    }

    @IsTest
    static void testGetAccountPlans(){

        Test.startTest();
        Account al = [SELECT Name FROM Account WHERE Name LIKE '%Test%' LIMIT 1];
        PageReference testPage = Page.EMEA_AccountPrintableView;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(al.Id));
        Test.setCurrentPage(testPage);
        ApexPages.StandardController sc = new  ApexPages.StandardController(al);
        EMEA_AccountPrintableViewController ext = new EMEA_AccountPrintableViewController(sc);
        List<EMEA_Account_Plan__c> accPlan = ext.getAccountPlans();
        for (EMEA_Account_Plan__c a : accPlan) {
             System.assertEquals('Test APL', a.EMEA_Account_Plan_Name__c);
        }
        Test.stopTest();
    }

	@IsTest
	static void testGetAccountSegmentation(){

        Test.startTest();
        Account al = [SELECT Name FROM Account WHERE Name LIKE '%Test%' LIMIT 1];
        PageReference testPage = Page.EMEA_AccountPrintableView;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(al.Id));
        Test.setCurrentPage(testPage);
        ApexPages.StandardController sc = new  ApexPages.StandardController(al);
        EMEA_AccountPrintableViewController ext = new EMEA_AccountPrintableViewController(sc);
        List<EMEA_Account_Segmentation__c> segmentationList  = ext.getAccountSegmentation();
        for (EMEA_Account_Segmentation__c segm : segmentationList) {
             System.assertEquals('Recon', segm.EMEA_Business_Unit__c);
        }
        System.assertEquals(5, segmentationList.size());
        Test.stopTest();
    }

    @IsTest
	static void testGetCompetitorAnalysis(){

        Test.startTest();
        Account al = [SELECT Name FROM Account WHERE Name LIKE '%Test%' LIMIT 1];
        PageReference testPage = Page.EMEA_AccountPrintableView;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(al.Id));
        Test.setCurrentPage(testPage);
        ApexPages.StandardController sc = new  ApexPages.StandardController(al);
        EMEA_AccountPrintableViewController ext = new EMEA_AccountPrintableViewController(sc);
        List<EMEA_Competitor_Analysis__c> competitorList = ext.getCompetitorAnalysis();
        for (EMEA_Competitor_Analysis__c analysis : competitorList) {
             System.assertEquals('Test Product', analysis.EMEA_Product__r.Name);
        }
        System.assertEquals(5, competitorList.size());
        Test.stopTest();
    }

    @IsTest
    static void testGetPartners(){

        Test.startTest();
        Account al = [SELECT Name FROM Account WHERE Name LIKE '%Test%' LIMIT 1];
        PageReference testPage = Page.EMEA_AccountPrintableView;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(al.Id));
        Test.setCurrentPage(testPage);
        ApexPages.StandardController sc = new  ApexPages.StandardController(al);
        EMEA_AccountPrintableViewController ext = new EMEA_AccountPrintableViewController(sc);
        List<Partner> partners = ext.getPartners();
        for (Partner partner : partners) {
            System.assertEquals('Member - Hospital', partner.Role);
        }
        System.assertEquals(1, partners.size());
        Test.stopTest();
    }
}