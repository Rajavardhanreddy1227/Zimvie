/************************************************************************
    Created by:     Prosenjit Saha
    Created Date:   5/22/2019
    Class Name:     surgeonProfileController
    purpose:        To print and Edit surgeon profile from 
                    Opportunity ID 
                    Print Description: Order of code to pass pdf page
                    1. Executive Summary 
                    2. Market Segmentation
                    3. Hospital Affiliations
                    4. Product Usage
                    5. Sunshine Payment
                    6. Event Registrations
                    7. Payers 
                    8. Public Engagements
                
*************************************************************************/

public class surgeonProfileController {
    
    //variables decaration
    public Map<String,decimal> SunShineSalesmap {get;set;}
    public Map<String,Map<Integer,Decimal>> SunShineSalesbyYears {get;set;}
    public account surgeonaccount {get;set;}
    public Opportunity OppDetails {get;set;}
    public string recordTypeId {get;set;}  
    public boolean showhipkneesection {get;set;} // render hip/knee section on page
    public string recTypeName {get;set;} // render hip/knee section on page
    public List<Market_Segmentation__c> Segmentation {get;set;}
    public string HipSegment {get;set;}
    public string KneeSegment {get;set;}
    public List<Healthcare_Surgeon_Relationship__c> HCFRelation {get;set;}
    public List<Task> Tasklist {get;set;}
    public GPL_Profile__c surgeonprofile {get;set;}
    public List<CampaignMember> campaignhistroylist {get;set;}
    public Map<integer,Map<String,decimal>> YearBrandTotal {get;set;} // Stores <year, <Brand, Brand Total>>
    public Map<integer,decimal> YearTotal {get;set;} //Stores year, YearTotal
    public Set<String> uniqueBrandName {get;set;} // Stores Unique Brand Name
    public List<Public_Engagement__c> publicengagements {get;set;}
    public List<Payor__c> payordata {get;set;}
    public integer mostrecentSSyear {get;set;}
    public Boolean displayPopup {get;set;}
    
    //Sections for pdf generation - This section declares variables for the pop up/ modal window
    public Boolean executiveSummary {get;set;}
    public Boolean MarketSegmenation {get;set;}
    public Boolean HospitalAffiliations {get;set;}
    public Boolean ProdUsage {get;set;}
    public Boolean SunshinePayment {get;set;}
    public Boolean EventRegistrations {get;set;}
    public Boolean Payers {get;set;}
    public Boolean PublEngagements {get;set;}
    
    
    //Wrapper class for sunshine Payment
    public class SSSale {
        public String CompanyName {get; set; }
        public Decimal amount {get; set;}   
        public Decimal Year1 {get; set;}  
        public Decimal Year2 {get; set;} 
        public Decimal Year3 {get; set;} 
        
        SSSale(String CompanyName, Decimal amount,Decimal Year1, Decimal Year2, Decimal Year3) {
            this.CompanyName = CompanyName;
            this.amount = amount;   
            this.Year1 = Year1;  
            this.Year2 = Year2;  
            this.Year3 = Year3; 
        }
    }
    
    //Wrapper class for Product Usage
    public class ProdUsage {
        
        public String ProductGroupName {get; set; }
        public String BrandName {get; set; }
        public Decimal Year1 {get; set;}  
        public Decimal Year2 {get; set;} 
        public Decimal Year3 {get; set;} 
        
        //Brand Name, This year %, Last Year %, LY-1 %
        ProdUsage(String BrandName, Decimal Year1, Decimal Year2, Decimal Year3) {
            this.BrandName = BrandName;
            this.Year1 = Year1;  
            this.Year2 = Year2;  
            this.Year3 = Year3;  
        }
    }

    //Main controller
    public surgeonProfileController(){
        string OppID = '';
        string SurgeonAccID = '';
        string SurgeonContactID = '';
        executiveSummary = TRUE; 
        string printsec = ''; 
        HipSegment = '';
        KneeSegment = ''; 
        showhipkneesection = false;
        OppID = ApexPages.currentPage().getParameters().get('id');
        printsec = ApexPages.currentPage().getParameters().containskey('prntsec')? ApexPages.currentPage().getParameters().get('prntsec'): '' ;
        if(printsec != ''){
            executiveSummary = printsec.substring(0,1)=='1'?TRUE:FALSE; 
            MarketSegmenation = printsec.substring(1,2)=='1'?TRUE:FALSE; 
            HospitalAffiliations = printsec.substring(2,3)=='1'?TRUE:FALSE; 
            ProdUsage = printsec.substring(3,4)=='1'?TRUE:FALSE; 
            SunshinePayment = printsec.substring(4,5)=='1'?TRUE:FALSE; 
            EventRegistrations= printsec.substring(5,6)=='1'?TRUE:FALSE; 
            Payers= printsec.substring(6,7)=='1'?TRUE:FALSE; 
            PublEngagements = printsec.substring(7,8)=='1'?TRUE:FALSE; 
        }
        //Query to get opportunity details
        for(Opportunity opps: [select   name
                                        , id
                                        , recordtypeID
                                        , recordtype.Name
                                        , amount
                                        , closedate
                                        , Surgeon_Name__c
                                        , Surgeon_Name__r.NPI__c
                                        , Surgeon_Name__r.name
                                        , Surgeon_Name__r.accountnumber
                                        , Surgeon_Name__r.phone
                                        , Surgeon_Name__r.fax
                                        , Surgeon_Name__r.PersonEmail
                                        , Surgeon_Name__r.X18_Digit_Contact_ID__pc
                                        , stagename 
                                        , probability
                                        , forecastcategoryname
                                        , description
                                        , owner.Name
                                        , owner.department
                                        , owner.email
                                        , owner.phone
                                        , territory_name__c
                                        , brand__c
                                        , segment__c 
                                        , backgound_previous_activities_meetings__c
                                        , Competitor__c 
                                        , Competitive_Units__c 
                                        , ASP__c
                                        , Rep__c
                                        , Hip_Competitor__c
                                        , Hip_Primary_Product__c
                                        , Hip_Revision_Product__c
                                        , FX_Competitive_Units__c
                                        , Fx_Estimated_ASP__c
                                        , Primary_Product_Units__c
                                        , Primary_Product_Estimated_ASP__c
                                        , Revision_Product_Units__c
                                        , Revision_Product_Estimated_ASP__c
                                        , Knee_Competitor__c
                                        , Uni_Knee_Product__c
                                        , Knee_Primary_Product__c
                                        , Knee_Revision_Product__c
                               from Opportunity where id= :OppID]){
            SurgeonAccID = opps.Surgeon_Name__c;
            SurgeonContactID = opps.Surgeon_Name__r.X18_Digit_Contact_ID__pc ; 
            OppDetails = Opps;                       
        }
        
        //Variables  
        Segmentation = new List<Market_Segmentation__c> ();
        HCFRelation = new List<Healthcare_Surgeon_Relationship__c>();
        SunShineSalesmap = new Map<String,decimal>{};  
        SunShineSalesbyYears = new Map<String, Map<Integer,decimal>>();
        Tasklist = new List<task> ();
        YearBrandTotal = new Map<integer,Map<String,decimal>> ();
        YearTotal = new Map<integer,decimal> ();
        uniqueBrandName = new Set<String>();
        campaignhistroylist = new List<CampaignMember>();
        publicengagements = new List<Public_Engagement__c>();
        payordata = new List<Payor__c>();
            
        //get surgeon details and surgeon profile
        if(SurgeonAccID != null){ // Start surgeon id check
            //surgeon account query
            surgeonaccount = [select id, name,NPI__c from account where id = :SurgeonAccID];
            surgeonprofile = new GPL_Profile__c ();
            
            //surgeon profile query
            for(GPL_Profile__c surgeonprof : [select Photo__c,PhotoId__c,MedicalSchool__c,Fellowship__c,Specialties__c, Devices__c, Procedures__c, residency__c
                  from GPL_Profile__c where Account__c = :SurgeonAccID]){
                surgeonprofile =    surgeonprof ;       
            }
            
            //Market Segementation Query         
            for(Market_Segmentation__c segments : [SELECT Zimmer_Biomet_Procedures__c
                                                         , Market_Procedures__c
                                                         , Surgeon_Name__c
                                                         , Product_Group__c
                                                         , Surgeon_Name__r.name
                                                         , Segementation__c
                                                         , procedure_Opportunity__c 
                                                         , Adjusted_Market_Procedures__c
                                                         //, Company__c
                                                         //, Primary_Product__c
                                                         //, Revision_Product__c
                                                 FROM   Market_Segmentation__c
                                                 where  Surgeon_Name__c 
                                                 =      :SurgeonAccID
                                                 ]){
                                                       
                Segmentation.add(segments) ;
                if(segments.product_Group__c == 'Hips') HipSegment = segments.Segementation__c ; 
                if(segments.product_Group__c == 'Knees') KneeSegment = segments.Segementation__c ; 
            }
            
            //Healthcare surgeon relationship query
            for(Healthcare_Surgeon_Relationship__c HCF : [select    name
                                                                    , Healthcare_Facility__r.name
                                                                    , City__c
                                                                    , State__c
                                                                    , Surgeon__c
                                                                    , Class_Description__c
                                                                    , Territory_Number__c
                                                                    , Healthcare_Facility__r.GPO_Account__r.name
                                                                    , Healthcare_Facility__r.Coalition_Account__r.name
                                                                    , Healthcare_Facility__r.IDN_Account__r.name
                                                             from       Healthcare_Surgeon_Relationship__c
                                                             where      Surgeon__c = :SurgeonAccID]){
                HCFRelation.add(HCF);    
            }  
            
            //Sun shine payment query -- Map <company name , Total payment amount>
            for (Sunshine_Payment__c sp : [
                    select
                            id ,
                            Physician__c  ,
                            Amount__c , 
                            Manufacturer__c ,
                            Payment_Date__c,
                            Payment_Reason__c,
                            Payment_Type__c
                    from    Sunshine_Payment__c
                    where   Physician__c = :surgeonaccount.id
                    AND     Manufacturer__c != null 
                    ORDER by Amount__c desc , Payment_Date__c desc 
                    ]) {
                if(SunShineSalesmap.size()==0 || !SunShineSalesmap.containskey(sp.Manufacturer__c.toUpperCase())){
                    SunShineSalesmap.put(sp.Manufacturer__c.toUpperCase(),sp.Amount__c);   
                    mostrecentSSyear = sp.Payment_Date__c.year(); 
                    Map <Integer, decimal> tempmap = new Map<integer, decimal>();
                    tempmap.put(sp.Payment_Date__c.year(), sp.Amount__c);
                    SunShineSalesbyYears.put(sp.Manufacturer__c.toUpperCase(),tempmap);
				
                }
                else{
                    decimal newamount ;
                    newamount = SunShineSalesmap.get(sp.Manufacturer__c.toUpperCase()) + sp.Amount__c;
                    SunShineSalesmap.remove(sp.Manufacturer__c.toUpperCase());
                    SunShineSalesmap.put(sp.Manufacturer__c.toUpperCase(),newamount);
                    if(sp.Payment_Date__c.year() != mostrecentSSyear && sp.Payment_Date__c.year() > mostrecentSSyear)  mostrecentSSyear = sp.Payment_Date__c.year();
                    if(!SunShineSalesbyYears.get(sp.Manufacturer__c.toUpperCase()).containskey(sp.Payment_Date__c.year())){
                           SunShineSalesbyYears.get(sp.Manufacturer__c.toUpperCase()).put(sp.Payment_Date__c.year(),sp.amount__c);
                    }
                    else{
                        decimal tempyeartotal = SunShineSalesbyYears.get(sp.Manufacturer__c.toUpperCase()).get(sp.Payment_Date__c.year()) + sp.amount__c ; 
                        SunShineSalesbyYears.get(sp.Manufacturer__c.toUpperCase()).remove(sp.Payment_Date__c.year());
                        SunShineSalesbyYears.get(sp.Manufacturer__c.toUpperCase()).put(sp.Payment_Date__c.year(),tempyeartotal);
                    }
                }                  
            }//end of for loop
            
            //Product Usage Query
            //get data of last 2 years
            date dtTime = date.newinstance(System.today().year()-2, 1, 1);
            for(Product_Usage__c prod : [
                select  id
                        , Surgeon__c
                        , GBI_Brand__c
                        , GBI_Sub_Brand__c
                        , GBI_Product_Group__c 
                        , Date__c
                        , Invoice_Sales_Amount__c
                from    Product_Usage__c
                where   Surgeon__c = :SurgeonAccID
                and     ( date__c > :dtTime OR date__c = THIS_YEAR )
                order by Date__c desc , Invoice_Sales_Amount__c]){
                    String Brand ; 
                    if(prod.GBI_Brand__c != null){
                        Brand = prod.GBI_Brand__c ; 
                    }
                    Else Brand = 'N/A'; //If no Brand name is available, then print N/A
                    decimal invoicesales = 0; 
                    if(prod.Invoice_Sales_Amount__c != null ){
                        invoicesales = prod.Invoice_Sales_Amount__c ; 
                    }                    
                    if(YearTotal.size() == 0 || !YearTotal.containsKey(prod.Date__c.year())){
                        map<string, decimal> tempmap = new map<string, decimal>();
                        YearTotal.put(prod.Date__c.year(),invoicesales);                       
                        tempmap.put(Brand,invoicesales);
                        uniqueBrandName.add(Brand.toUpperCase());
                        YearBrandTotal.put(prod.Date__c.year(), tempmap);
                    }   
                    else{
                        decimal newtotal = YearTotal.get(prod.Date__c.year())+1;
                        YearTotal.remove(prod.Date__c.year());
                        YearTotal.put(prod.Date__c.year(),newtotal);
                        if(!YearBrandTotal.get(prod.Date__c.year()).containskey(Brand.toUpperCase())){
                            YearBrandTotal.get(prod.Date__c.year()).put(Brand.toUpperCase() , invoicesales);    
                            uniqueBrandName.add(Brand.toUpperCase());
                        }
                        else{
                            decimal newbrandtotal = YearBrandTotal.get(prod.Date__c.year()).get(Brand.toUpperCase() ) + invoicesales ; 
                            YearBrandTotal.get(prod.Date__c.year()).remove(Brand.toUpperCase());
                            YearBrandTotal.get(prod.Date__c.year()).put(Brand.toUpperCase(),newbrandtotal);
                            uniqueBrandName.add(Brand.toUpperCase());
                        }
                    }
            }// end Product usage query
            
            //Start Campaign menmber query
            if(SurgeonContactID != null || SurgeonContactID != ''){
                for(CampaignMember member : [   select      id
                                                            , ContactId
                                                            , CampaignId
                                                            , HasResponded
                                                            , Campaign.name
                                                            , Campaign.enddate
                                                            , Campaign.StartDate
                                                            , Status
                                                            , Campaign.Type
                                                            , Campaign.Segment__c
                                                            , Campaign.Owner.name
                                            from            CampaignMember
                                            where           ContactId = :SurgeonContactID
                                            AND             Campaign.enddate > = :dtTime
                                            order by        Campaign.enddate desc limit 1000]){
                    
                    campaignhistroylist.add(member);
                }
            }//End Campaign menmber query
            
            //Start Public Engagement Query
            if(SurgeonContactID != null || SurgeonContactID != ''){
                for(Public_Engagement__c pubeng : [ select      id
                                                                , Date__c
                                                                , Surgeon_del__c 
                                                                , Type__c
                                                                , Name__c
                                                                , Role__c
                                                   from         Public_Engagement__c
                                                   where        Surgeon_del__c     = :SurgeonAccID 
                                                   OR           Doctor__c = :SurgeonContactID
                                                   order by     Date__c desc]){
                    publicengagements.add(pubeng);      
                 }
            }
            // End Public Engagement Query
            
            //Start Payer Query 
            for(Payor__c payorcmpny : [Select       id
                                                    , Precent__c
                                                    , Date_Reported__c
                                                    , Name
                                                    , Physician__c
                                      from          Payor__c
                                      where         Physician__c = :SurgeonAccID
                                      order by      Date_Reported__c desc]){
                payordata.add(payorcmpny);      
            }
            //End Payer Query
            
        }// end surgeon id check
        
        //Task query
        if(OppDetails != null){
            for(task tsk :                      [SELECT subject
                                                         , owner.name
                                                         , whoid
                                                         , ownerID
                                                         , status
                                                         , ActivityDate
                                                         , Comment__c
                                                         , CallDisposition
                                                         , LastModifiedDate 
                                                         , id
                                                 FROM   task
                                                 where  WhatId 
                                                 =      :OppDetails.id
                                                 ]){
                                                       
                Tasklist.add(tsk) ;
            }
        }
        
        //show/hide hip/knee section
        recTypeChanged();
                
    } // End of controller constructor
    
    //Wrapper class generation for sun shine payment
    public SSSale[] getSunShineSales() {
        SSSale[] Sales = new SSSale[] {};
        if(SunShineSalesmap.size() > 0){
            for(String CompanyName : SunShineSalesbyYears.keySet()){
                decimal year1total = 0; 
                decimal year2total = 0; 
                decimal year3total = 0; 
                if(SunShineSalesbyYears.get(CompanyName).containskey(mostrecentSSyear)){
                    year1total = SunShineSalesbyYears.get(CompanyName).get(mostrecentSSyear) ; 
                }  
                if(SunShineSalesbyYears.get(CompanyName).containskey(mostrecentSSyear-1)){
                    year2total = SunShineSalesbyYears.get(CompanyName).get(mostrecentSSyear-1) ; 
                } 
                if(SunShineSalesbyYears.get(CompanyName).containskey(mostrecentSSyear-2)){
                    year3total = SunShineSalesbyYears.get(CompanyName).get(mostrecentSSyear-2) ; 
                } 
                Sales.add(new SSSale(CompanyName,SunShineSalesmap.get(CompanyName),year1total,year2total,year2total));
            }
        }
        return sales;
    } // End of Wrapper Method
    
    //Wrapper class generation for Product Usage
    public ProdUsage[] getProductUsage() {
        ProdUsage[] ProdUse = new ProdUsage[] {};
        if(uniqueBrandName.size() > 0 && YearBrandTotal.size() > 0){
            integer thisyear = system.today().year();
            
            for(String BrandName : uniqueBrandName ){
                decimal year1total = 0; 
                decimal year2total = 0; 
                decimal year3total = 0; 
                if( YearBrandTotal.Containskey(thisyear) && YearBrandTotal.get(thisyear).containskey(BrandName)){
                    year1total = YearBrandTotal.get(thisyear).get(BrandName);
                } 
                if( YearBrandTotal.Containskey(thisyear-1) && YearBrandTotal.get(thisyear-1).containskey(BrandName)){
                    year2total = YearBrandTotal.get(thisyear-1).get(BrandName);
                } 
                if(YearBrandTotal.Containskey(thisyear-2) && YearBrandTotal.get(thisyear-2).containskey(BrandName)){
                    year3total = YearBrandTotal.get(thisyear-2).get(BrandName);
                } 
                ProdUse.add(new ProdUsage(BrandName
                                          , year1total 
                                          , year2total 
                                          , year3total ));        
            }
        }
        return ProdUse;
    } // End of Wrapper Method     
    
    public PageReference SaveOpp() {
        system.debug('Opportunity to update-->>'+ OppDetails.Amount); 
       
        
        OppDetails.Amount = ((OppDetails.FX_Competitive_Units__c != null ? OppDetails.FX_Competitive_Units__c : 0 ) * (OppDetails.Fx_Estimated_ASP__c != null ? OppDetails.Fx_Estimated_ASP__c : 0)) 
                                + ((OppDetails.Primary_Product_Units__c != null ? OppDetails.Primary_Product_Units__c : 0 ) * ( OppDetails.Primary_Product_Estimated_ASP__c!= null ? OppDetails.Primary_Product_Estimated_ASP__c : 0))
                                + ((OppDetails.Revision_Product_Units__c != null ? OppDetails.Revision_Product_Units__c : 0 ) * (OppDetails.Revision_Product_Estimated_ASP__c  != null ? OppDetails.Revision_Product_Estimated_ASP__c : 0));
           
        update OppDetails ; 
        update Segmentation ; 
        if(Tasklist.size() > 0) upsert Tasklist ; 
        PageReference refreshPage = new PageReference ('/apex/SurgeonProfileEdit?id='+OppDetails.id);
        refreshPage.setRedirect(true);
        return refreshPage;
    } 
    public PageReference generatepdf() {
        // Send the user to the detail page for the new account.
        PageReference pdfPage = new PageReference ('/apex/SurgeonProfilePDF?id='+OppDetails.id);
        pdfPage.setRedirect(true);
        return pdfPage;
    }
    
    
    public void addTask(){
        task newtask = new task();
        newtask.WhatId = OppDetails.id;
        newtask.ownerID = UserInfo.getUserId() ;
        Tasklist.add(newtask);      
        /* Add one inner row everytime an outer row is created */
    }
    
    //pop up  related code
    public void showPopup(){      
        displayPopup = true;
    }
    
    public void closePopup() {
        displayPopup = false;        
    }
    
    public PageReference redirectPopup() {
        displayPopup = false;
        //Please uncomment below 3 statements and replace YourObjectId
        // PageReference p=new Pagereference('/'+YourObjectId);
        //  p.setRedirect(true);
        //  return p;
        String strfinal = '';
        if(executiveSummary){
            strfinal = strfinal + '1';
        }else strfinal = strfinal + '0';
        if(MarketSegmenation){
            strfinal = strfinal + '1';
        } else strfinal = strfinal + '0';
        if(HospitalAffiliations){
            strfinal = strfinal + '1';
        } else strfinal = strfinal + '0';
        if(ProdUsage){
            strfinal = strfinal + '1';
        } else strfinal = strfinal + '0';
        if(SunshinePayment){
            strfinal = strfinal + '1';
        } else strfinal = strfinal + '0';
        if(EventRegistrations){
            strfinal = strfinal + '1';
        } else strfinal = strfinal + '0';
        if(Payers){
            strfinal = strfinal + '1';
        } else strfinal = strfinal + '0';
        if(PublEngagements){
            strfinal = strfinal + '1';
        } else strfinal = strfinal + '0';
        
        PageReference pdfPage = new PageReference ('/apex/SurgeonProfilePDF?id='+OppDetails.id+'&prntsec='+strfinal);
        pdfPage.setRedirect(true);
        return pdfPage;
        
    }
    
    // show/hide hip/knee section on page
    public PageReference recTypeChanged(){
        system.debug('--recTypeName--'+OppDetails.recordtypeId);
        system.debug('--showhipkneesection--'+showhipkneesection);
        
        if(OppDetails.recordtypeId == '012C0000000GaIOIA0' || OppDetails.recordtypeId == '012800000002ReSAAU'){
            showhipkneesection = true;
        }
        else{
            showhipkneesection = false;
        }
        return null;
    }
    
}// End of controller