global class Services_Inventory {

     global class Physician_Locator_Output{
         
        WebService String MedicalPracticeId;
        WebService String PhysicianId;
        WebService String FirstName;
        WebService String MiddleName;
        WebService String LastName;     
        WebService String Suffix;
        WebService String PracticeName;
        WebService String office_Street;
        WebService String office_City;
        WebService String office_StateOrProvince;
        WebService String office_ZipCodeOrPostalCode;
        WebService String office_Country;
        WebService String PhoneNumber;
        WebService String FaxNumber;
        WebService String WebsiteUrl;
    //  WebService String Undergraduate;    // not available
        WebService String Graduate;
        WebService String Residency;
        WebService String Fellowship;
        WebService String Hospital_Affiliations;  
    //  WebService String Joint_Procedure_Specialties;
        WebService String MIS_Flag;
     // WebService String ZipCode_PostalCodeDistance; 
        WebService String Physician_Special_Interest;
        WebService String Medical_degree; 
        WebService String Specialties;
        WebService String Medical_practice_Street;
        WebService String Medical_practice_City;
        WebService String Medical_practice_StateOrProvince;
        WebService String Medical_practice_PostalCode;
        WebService String Medical_practice_Country;
        
     } 
     //Services_Inventory.zipCodeMethod(zipCodeList, SpecialityCondition)
     //Services_Inventory.StateCountryMethod(state, country, SpecialityCondition)
     //Services_Inventory.MyPhysicianMethod(MedicalPracticeId, physicianId)
     Webservice static list<Physician_Locator_Output> zipCodeMethod(list<String> zipCodeList , integer SpecialityNumber){
        
           string SpecialityCondition = SpConditionCode(SpecialityNumber);
           
      list<Physician_Locator_Output> result = searchResults(zipCodeList, '','', '', '', SpecialityCondition, true, false, false); 
                                           
          
        return result;
     }
     
     Webservice static list<Physician_Locator_Output> StateCountryMethod(String state,String country ,integer SpecialityNumber){
 
        
        string SpecialityCondition = SpConditionCode(SpecialityNumber);
        list<String> zipCodeList = new list<String>();
        list<Physician_Locator_Output> result = searchResults(zipCodeList, state, Country, '','', SpecialityCondition, false, true, false);
         
        return result;  
             
     }
     Webservice static Physician_Locator_Output MyPhysicianMethod(String MedicalPracticeId , String physicianId){

        list<String> zipCodeList = new list<String>();
        list<Physician_Locator_Output> result = searchResults(zipCodeList, '', '', MedicalPracticeId,physicianId,'',false, false , true); 
                                                                               
        
     // Physician_Locator_Output result = new Physician_Locator_Output();
     if(!result.isEmpty())
        return result[0];
        else
        return null;         
     } 
     
  
  
  //mehod used to get the condition from condition Number
  
  public static String SpConditionCode(integer SpecialityNumber)
  {

    if(SpecialityNumber ==0)
    return 'ALL';
    string ss = string.valueof(SpecialityNumber);
    Phy_Country_Codes__c pcc = Phy_Country_Codes__c.getvalues(ss);
    if(pcc != null)
    return pcc.Condition_Code__c ;
    else
    return 'error';
  }
  
     // method used for other webservice to return result
     
     public static list<Physician_Locator_Output> searchResults(list<String> zipCodeList ,String state, String Country , 
                                                                String MedicalPracticeId, String physicianId , String SpecialityCondition,
                                                                 Boolean isZip,Boolean isStateorCountry,Boolean isMyPhy){
        
      //  String MedRecTypeId = RecordTypeHelper.getRecordTypeId('Account','Medical Practice');
      //String MedRecTypeId = [Select Id, sObjectType, Name From RecordType where sObjectType = 'Account' and Name ='Medical Practice'].Id;
      String MedRecTypeId = [Select Id, sObjectType, Name From RecordType where sObjectType = 'Account' and DeveloperName ='Practice'].Id;
                list<Physician_Locator_Output> result = new list<Physician_Locator_Output>();
                 map<id,Account> MatchAccount;
        if(isZip){
        MatchAccount = new map<id,Account>([select id,name,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet, 
                                          Website,Phone,Fax   from Account where RecordTypeId= :MedRecTypeId and 
                                           ShippingPostalCode IN :zipCodeList limit 9999]);
        
        }else if(isStateorCountry){
        MatchAccount = new map<id,Account>([select id,name,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet, 
                                          Website,Phone,Fax   from Account where RecordTypeId= :MedRecTypeId and 
                                           ShippingState =:state and ShippingCountry = :Country limit 300]);
        }else if (isMyPhy){
        MatchAccount = new map<id,Account>([select id,name,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet, 
                                          Website,Phone,Fax   from Account where id = :MedicalPracticeId]); 
                                                
        }
     //   System.debug('Result is------------------------------------>' + MatchAccount);
        
    if(!MatchAccount.isEmpty()){                                                               
     // map<String,map<String,String>> fullMap = new map<String,map<String,String>>();
        map<String,list<Practice_Surgeon_Link__c>> SuVsPr = new map<String,list<Practice_Surgeon_Link__c>>();
        Set<String> SarId = new Set<String>();
        list<Practice_Surgeon_Link__c> PSL;
        if(isMyPhy){
                       PSL = [select id,Practice__c,Surgeon__c,Surgeon__r.FirstName,Surgeon__r.Middle_Name__c, 
                                                    Surgeon__r.LastName,Surgeon__r.Suffix__c,Surgeon__r.Technique__c,
                                                    Surgeon__r.Expertise_integration_purpose__c,Surgeon__r.Medical_School__c,
                                                    Surgeon__r.Residency__c,Surgeon__r.Fellowship__c,Surgeon__r.Medical_Degree__c,
                                                    Surgeon__r.Physician_Specialty__c,Surgeon__r.PersonMailingCity,
                                                    Surgeon__r.PersonMailingCountry,Surgeon__r.PersonMailingPostalCode,
                                                    Surgeon__r.PersonMailingState,Surgeon__r.PersonMailingStreet,Surgeon__r.MDM_SAP_ID__c,
                                                    Surgeon__r.Physicians_Locator__c
                                                    from Practice_Surgeon_Link__c where Practice__c =:MedicalPracticeId 
                                                    and Surgeon__r.MDM_SAP_ID__c = :physicianId];
        System.debug('Size is--------------------->' +PSL.size());
        if(!PSL.isEmpty())
        SpecialityCondition = PSL[0].Surgeon__r.Physician_Specialty__c;
        }
        else{
        PSL = [select id,Practice__c,Surgeon__c,Surgeon__r.FirstName,Surgeon__r.Middle_Name__c, 
                                                    Surgeon__r.LastName,Surgeon__r.Suffix__c,Surgeon__r.Technique__c,
                                                    Surgeon__r.Expertise_integration_purpose__c,Surgeon__r.Medical_School__c,
                                                    Surgeon__r.Residency__c,Surgeon__r.Fellowship__c,Surgeon__r.Medical_Degree__c,
                                                    Surgeon__r.Physician_Specialty__c,Surgeon__r.PersonMailingCity,
                                                    Surgeon__r.PersonMailingCountry,Surgeon__r.PersonMailingPostalCode,
                                                    Surgeon__r.PersonMailingState,Surgeon__r.PersonMailingStreet,Surgeon__r.MDM_SAP_ID__c,
                                                    Surgeon__r.Physicians_Locator__c
                                                    from Practice_Surgeon_Link__c where Practice__c IN :MatchAccount.keySet()];       
                                                //    and (Practice_Surgeon_Link__c.Surgeon__r.Physician_Specialty__c.contains(SpecialityCondition))];
        }
    system.debug('inside else------------------------------');
    list<String> ValidPractice = new list<String>();
    
  if(!PSL.isEmpty()){
     //Add all the Medical practice with associated physican
  //   for(Account ma :MatchAccount.values())
   //  {
        
        
            for(Practice_Surgeon_Link__c pp :PSL)
            {
             list<Practice_Surgeon_Link__c> temp = new list<Practice_Surgeon_Link__c>();
             if(!SuVsPr.containsKey(pp.Practice__c))
             {
                temp.add(pp);
                SuVsPr.put(pp.Practice__c,temp);
                ValidPractice.add(pp.Practice__c);
        //        SarId.add(pp.Surgeon__c);
                
             }
             else 
             {
                temp = SuVsPr.get(pp.Practice__c);
                temp.add(pp);
                SuVsPr.put(pp.Practice__c,temp);
                
             }
            
            
             /*
                if(pp.Practice__c == ma.id)
                {
                    temp.add(pp);
                }
                */
            
   /*
        if(!temp.isEmpty())
        {
            SuVsPr.put(ma.id,temp);
            ValidPractice.add(ma.id);
        }
        }
        */
  //  
  }  
    }
   
    if(!ValidPractice.isEmpty())
        
    { 
     // Collect all physician Id
        for(Practice_Surgeon_Link__c pp :PSL)
        {
            SarId.add(pp.Surgeon__c);
            //SuVsPr.put(pp.Practice__c);
        }
       
        list<String> SarId1 = new list<String>();
        SarId1.addAll(SarId);
        
        
      map<String,String> HcVsPy = new map<String,String>();
      
     list<Healthcare_Surgeon_Relationship__c> HSR = [select id,Healthcare_Facility__c,Healthcare_Facility__r.Name,
                                                            Healthcare_Facility__r.ShippingCity,Healthcare_Facility__r.ShippingCountry,                                                           
                                                            Healthcare_Facility__r.ShippingState,Surgeon__c
                                                            from Healthcare_Surgeon_Relationship__c where Surgeon__c IN :SarId];
     
     // map for physiacn associated with Health care facility
  //   for(integer i=0 ;i<SarId1.size();i++)
  //   {
     //   String temp;
        for(Healthcare_Surgeon_Relationship__c hh :HSR)
        {
         //   if(SarId1[i]==hh.Surgeon__c)
          //  {
              String temp = '';
            if(!HcVsPy.containsKey(hh.Surgeon__c)){
              //  if(temp =='' || temp==null) 
              //  {
              //  temp='';
                temp = hh.Healthcare_Facility__r.Name + ',' + hh.Healthcare_Facility__r.ShippingCity;
                temp = temp + ',' + hh.Healthcare_Facility__r.ShippingState + ',';
                temp = temp + hh.Healthcare_Facility__r.ShippingCountry;
                HcVsPy.put(hh.Surgeon__c,temp);
                }
                else
                {
                temp = HcVsPy.get(hh.Surgeon__c);
                temp = temp + '>' + hh.Healthcare_Facility__r.Name + ',' + hh.Healthcare_Facility__r.ShippingCity;
                temp = temp + ',' + hh.Healthcare_Facility__r.ShippingState + ',';
                temp = temp + hh.Healthcare_Facility__r.ShippingCountry;                    
                }
            }
   //     }
        
     //   if(temp!='')
        
   //  } 
    Boolean isPass = false;
    Boolean isCheck = false;
    if(SpecialityCondition == 'ALL'){
        isPass = true ;
    }
   // else{
   //   if(ps.Surgeon__r.Physician_Specialty__c !=null){
  //        isPass = true ;
   //   }
  //  }
    
        System.debug('Valid practise size is--------------->' + ValidPractice.size());
         for(integer i=0 ; i<ValidPractice.size();i++)
         {
             for(Practice_Surgeon_Link__c ps :SuVsPr.get(ValidPractice[i]))
             {
              //  System.debug('CONDITION IS-------->' +ps.Surgeon__r.Physician_Specialty__c);
              //  System.debug('Surgen IS-------->' +SpecialityCondition);
               if(isPass)
               {
                 if(ps.Surgeon__r.Physicians_Locator__c == true)
                 isCheck = true;
                 else
                 isCheck = false;
               }
               else
               { 
                  system.debug('else condition phy spec ------------------' + ps.Surgeon__r.Physician_Specialty__c);
                  system.debug('else condition phy locator ------------------' + ps.Surgeon__r.Physicians_Locator__c);
                  if(ps.Surgeon__r.Physician_Specialty__c !=null){
                    
                if(ps.Surgeon__r.Physician_Specialty__c.contains(SpecialityCondition) && ps.Surgeon__r.Physicians_Locator__c == true)
                    isCheck = true;
                else
                    isCheck = false;
               }
               else
                   isCheck = false;
               }  
           System.debug('IsCheck value is------------------------>' +isCheck);
           if(isCheck){     
            Physician_Locator_Output po = new Physician_Locator_Output();
            po.MedicalPracticeId = ps.Practice__c;
            po.PhysicianId = ps.Surgeon__r.MDM_SAP_ID__c;
            po.FirstName= ps.Surgeon__r.FirstName;
            po.MiddleName= ps.Surgeon__r.Middle_Name__c;
            po.LastName= ps.Surgeon__r.LastName;
            po.Suffix= ps.Surgeon__r.Suffix__c;
            po.Medical_degree = ps.Surgeon__r.Medical_Degree__c;
            po.MIS_Flag = ps.Surgeon__r.Technique__c;           
            po.Physician_Special_Interest = ps.Surgeon__r.Expertise_integration_purpose__c;
            po.Graduate= ps.Surgeon__r.Medical_School__c;
            po.Residency = ps.Surgeon__r.Residency__c;
            po.Fellowship= ps.Surgeon__r.Fellowship__c;
            po.Specialties = ps.Surgeon__r.Physician_Specialty__c;
            po.office_Street= ps.Surgeon__r.PersonMailingStreet;            
            po.office_City = ps.Surgeon__r.PersonMailingCity;
            po.office_StateOrProvince = ps.Surgeon__r.PersonMailingState;
            po.office_ZipCodeOrPostalCode = ps.Surgeon__r.PersonMailingPostalCode;
            po.office_Country = ps.Surgeon__r.PersonMailingCountry;
            po.PracticeName = MatchAccount.get(ValidPractice[i]).name;
            po.PhoneNumber = MatchAccount.get(ValidPractice[i]).phone;
            po.FaxNumber=MatchAccount.get(ValidPractice[i]).Fax;
            po.WebsiteUrl=MatchAccount.get(ValidPractice[i]).Website;
            po.Medical_practice_Street = MatchAccount.get(ValidPractice[i]).ShippingStreet;
            po.Medical_practice_City = MatchAccount.get(ValidPractice[i]).ShippingCity;
            po.Medical_practice_PostalCode = MatchAccount.get(ValidPractice[i]).ShippingPostalCode;
            po.Medical_practice_StateOrProvince = MatchAccount.get(ValidPractice[i]).ShippingState;
            po.Medical_practice_Country = MatchAccount.get(ValidPractice[i]).ShippingCountry;
            if(HcVsPy.containsKey(ps.Surgeon__c)) 
            po.Hospital_Affiliations = HcVsPy.get(ps.Surgeon__c);

         // po.Joint_Procedure_Specialties = ta.Speciality_Type__c;

            result.add(po);
                } 
               
             }
         
         
         }

    }// End of valid practice  
  
  }// End of match Account loop
               return result;
        
     }
}