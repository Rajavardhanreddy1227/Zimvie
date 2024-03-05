/************************************************************************
Created by:		Prosenjit Saha
Created Date: 	5/23/2019
Class Name: 	surgeonProfileControllerTest
purpose:		Test Class for surgeonProfileController 
*************************************************************************/
@isTest 
public class surgeonProfileControllerTest 
{
    static testMethod void testMethod1() {
        
        //create HCF account
        Id hcfrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Healthcare Facility').getRecordTypeId();
        Account testhcfAccount = new Account();
        testhcfAccount.name ='Test Account ' ;
        testhcfAccount.recordtypeid = hcfrecordTypeId;
        insert testhcfAccount ;
        
        //create contact
        contact cont = new contact ();
        cont.Lastname = 'Test';
        cont.AccountId = testhcfAccount.id;
        Insert cont;        
        
        //Create Surgeon account
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Physician').getRecordTypeId();
        Account testSurgeonAccount = new Account();
        testSurgeonAccount.FirstName ='Test Account record' ;
        testSurgeonAccount.LastName  ='Test Account record' ;
        testSurgeonAccount.NPI__c = '123123' ;
        testSurgeonAccount.accountnumber = '123123123' ;
        testSurgeonAccount.phone = '1234567890';
        testSurgeonAccount.fax = '1234567890';
        testSurgeonAccount.PersonEmail = 'Test@test.com' ; 
        testSurgeonAccount.recordtypeid = recordTypeId; 
        testSurgeonAccount.PersonMailingCountry = 'US';
        testSurgeonAccount.PersonMailingCity = 'Warsaw';
        testSurgeonAccount.PersonMailingState = 'IN';
        testSurgeonAccount.PersonMailingStreet = 'E M St';
        testSurgeonAccount.PersonMailingPostalCode = '46580'; 
        insert testSurgeonAccount;
        
        //create Opportunity
        Opportunity Opps = new Opportunity();
        Opps.name = 'Test Opportunity' ; 
        Opps.amount = 10000;
        Opps.closedate = date.today() + 7 ; 
        Opps.stagename = 'Discover';
        Opps.probability = .25 ; 
        //Opps.forecastcategoryname = '';
        Opps.description = '';
        Opps.territory_name__c = 'ZB Empire';
        Opps.brand__c = 'Test';
        Opps.segment__c = '';
        Opps.backgound_previous_activities_meetings__c ='Test';
        Opps.Competitor__c = 'DePuy';
        Opps.Surgeon_Name__c = testSurgeonAccount.id;
        insert Opps;
        
        //Create GPL Profile 
        GPL_Profile__c gpl = new GPL_Profile__c ();
        gpl.Picture_Id__c = 'Test'; 
        gpl.MedicalSchool__c = 'Test Med School';
        gpl.Fellowship__c = 'test fellowship';
        gpl.Specialties__c = 'test Hips';
        gpl.Devices__c = 'test device';
        gpl.Procedures__c = 'Test Procedure'; 
        gpl.Account__c =  testSurgeonAccount.id;
        insert gpl;
        
        //insert market segmentation
        Market_Segmentation__c mktseg = new Market_Segmentation__c ();
        mktseg.Zimmer_Biomet_Procedures__c = 10;
        mktseg.Market_Procedures__c = 100;
        mktseg.Product_Group__c = 'Hips';
        mktseg.Segementation__c = 'Gold';
        mktseg.Surgeon_Name__c = testSurgeonAccount.id; 
        insert mktseg; 
        
        //insert task
        task tasklist = new task ();
        tasklist.subject = 'Test Task';
        tasklist.status = 'Not Started';
        tasklist.ActivityDate = date.today(); 
        tasklist.Comment__c = 'test'; 
        tasklist.WhatId = Opps.id;
        insert tasklist;
        
        //insert Healthcare Surgeon Relationship
        Healthcare_Surgeon_Relationship__c hcfrel = new Healthcare_Surgeon_Relationship__c();
        hcfrel.Surgeon__c = testSurgeonAccount.id ; 
        hcfrel.Healthcare_Facility__c = testhcfAccount.id;
        insert hcfrel;
        
        
        //insert sunshine payment
        List<Sunshine_Payment__c> insertsunshine = new List<Sunshine_Payment__c>();
        Sunshine_Payment__c sunshine1 = new Sunshine_Payment__c ();
        sunshine1.Physician__c = testSurgeonAccount.id; 
        sunshine1.Amount__c = 200;
        sunshine1.Manufacturer__c = 'DePuy';
        sunshine1.Payment_Date__c = date.today()-30;
        sunshine1.Payment_Reason__c = 'Test';
        insertsunshine.add(sunshine1);
        
        Sunshine_Payment__c sunshine2 = new Sunshine_Payment__c ();
        sunshine2.Physician__c = testSurgeonAccount.id; 
        sunshine2.Amount__c = 200;
        sunshine2.Manufacturer__c = 'Zimmer Biomet';
        sunshine2.Payment_Date__c = date.today()-60;
        sunshine2.Payment_Reason__c = 'Test';
        insertsunshine.add(sunshine2);
        
        Sunshine_Payment__c sunshine3 = new Sunshine_Payment__c ();
        sunshine3.Physician__c = testSurgeonAccount.id; 
        sunshine3.Amount__c = 200;
        sunshine3.Manufacturer__c = 'DePuy';
        sunshine3.Payment_Date__c = date.today()-90;
        sunshine3.Payment_Reason__c = 'Test';
        insertsunshine.add(sunshine3);
        
        Sunshine_Payment__c sunshine4 = new Sunshine_Payment__c ();
        sunshine4.Physician__c = testSurgeonAccount.id; 
        sunshine4.Amount__c = 200;
        sunshine4.Manufacturer__c = 'Zimmer Biomet';
        sunshine4.Payment_Date__c = date.today()-365;
        sunshine4.Payment_Reason__c = 'Test';
        insertsunshine.add(sunshine4);
        
        Sunshine_Payment__c sunshine5 = new Sunshine_Payment__c ();
        sunshine5.Physician__c = testSurgeonAccount.id; 
        sunshine5.Amount__c = 200;
        sunshine5.Manufacturer__c = 'Zimmer Biomet';
        sunshine5.Payment_Date__c = date.today()-750;
        sunshine5.Payment_Reason__c = 'Test';
        insertsunshine.add(sunshine5);
        
        insert insertsunshine;
        
        //insert Campaign
        Campaign camp = new Campaign ();
        camp.name = 'Test Campaign'; 
        camp.enddate = date.today()-90;
        insert camp;
        
        //insert Event Registration - campaign members
        CampaignMember campmember = new CampaignMember ();
        campmember.CampaignId = camp.id;
        campmember.ContactId = cont.id;
        insert campmember; 
        
        //insert public engagement 
        Public_Engagement__c pubeng =  new Public_Engagement__c();
        pubeng.Name__c = 'Test' ;
        pubeng.Doctor__c = cont.id;
        pubeng.Role__c = 'Publisher'; 
        pubeng.Date__c = date.today();
        Insert pubeng ; 
        
        //Insert Payers
        Payor__c payer = new Payor__c ();
        payer.Physician__c = testSurgeonAccount.id;  
        payer.Name = 'Test'; 
        payer.Date_Reported__c= date.today();
        insert payer; 
        
        //insert Product Usage
        List<Product_Usage__c> Produsagelist = new List<Product_Usage__c>();
        Product_Usage__c produsage1 = new Product_Usage__c();
        produsage1.Surgeon__c = testSurgeonAccount.id;  
        produsage1.GBI_Brand__c = 'Test1';
        produsage1.Date__c = date.today();
        produsage1.Invoice_Sales_Amount__c = 1000; 
        Produsagelist.add(produsage1) ;
        Product_Usage__c produsage2 = new Product_Usage__c();
        produsage2.Surgeon__c = testSurgeonAccount.id;  
        produsage2.GBI_Brand__c = 'Test2';
        produsage2.Date__c = date.today()-365;
        produsage2.Invoice_Sales_Amount__c = 1000; 
        Produsagelist.add( produsage2) ;
        Product_Usage__c produsage3 = new Product_Usage__c();
        produsage3.Surgeon__c = testSurgeonAccount.id;  
        produsage3.GBI_Brand__c = 'Test1';
        produsage3.Date__c = date.today();
        produsage3.Invoice_Sales_Amount__c = 1000; 
        Produsagelist.add( produsage3) ;
        Product_Usage__c produsage4 = new Product_Usage__c();
        produsage4.Surgeon__c = testSurgeonAccount.id;  
        //produsage4.GBI_Brand__c = null;
        produsage4.Date__c = date.today();
        produsage4.Invoice_Sales_Amount__c = 1000; 
        Produsagelist.add( produsage4) ;
        Product_Usage__c produsage5 = new Product_Usage__c();
        produsage5.Surgeon__c = testSurgeonAccount.id;  
        produsage5.GBI_Brand__c = 'Test1';
        produsage5.Date__c = date.today();
        produsage5.Invoice_Sales_Amount__c = 5000; 
        Produsagelist.add( produsage5) ;
        Product_Usage__c produsage6 = new Product_Usage__c();
        produsage6.Surgeon__c = testSurgeonAccount.id;  
        produsage6.GBI_Brand__c = 'Test9';
        produsage6.Date__c = date.today()-700;
        produsage6.Invoice_Sales_Amount__c = 5000; 
        Produsagelist.add( produsage6) ;
        Product_Usage__c produsage7 = new Product_Usage__c();
        produsage7.Surgeon__c = testSurgeonAccount.id;  
        produsage7.GBI_Brand__c = 'Test1';
        produsage7.Date__c = date.today()-1095;
        produsage7.Invoice_Sales_Amount__c = 5000; 
        Produsagelist.add( produsage7) ;
        Insert Produsagelist; 
        
        Test.StartTest(); 
        
        PageReference pageRef = Page.SurgeonProfilePDF; 
        pageRef.getParameters().put('id', String.valueOf(Opps.Id));
        Test.setCurrentPage(pageRef);
        
        surgeonProfileController testSurgeonPlan = new surgeonProfileController();
        testSurgeonPlan.getSunShineSales();
        testSurgeonPlan.getProductUsage();
        testSurgeonPlan.SaveOpp();
        testSurgeonPlan.generatepdf();
        testSurgeonPlan.addTask();
        testSurgeonPlan.showPopup();
        testSurgeonPlan.closePopup();
        
        Test.StopTest();
    }
}