global class Distributor_Locater_Updated {


   global class Distributor_Locator_Output{
    
      WebService String DistributorId;
      WebService String Distributor_name;
      WebService String AddressLine1;
      WebService String City;
      WebService String StateOrProvince;
      WebService String ZipCodeOrPostalCode;
      WebService String Country;
      WebService String OfficePhone;
      WebService String SecondaryPhone;
      WebService String FaxNumber;
      WebService String Email;
      WebService String WebsiteUrl;
      WebService String Specialty;
      
   } 
 
     //  System.debug('result------------->' +Distributor_Locater_Updated.zipCodeMethod('23'));
       //System.debug('Result is------------>'  +Distributor_Locater_Udated.zipCodeMethod('1234'));
       Webservice static list<Distributor_Locator_Output> zipCodeMethod(String zipCodeInput){
         
          list<Distributor_Locator_Output> result = 

DistributerResult(zipCodeInput,'','',true,false,false);
          
          return result;
                         
       }
       
       Webservice static list<Distributor_Locator_Output> countryMethod(String Country){
         
          list<Distributor_Locator_Output> result = 

DistributerResult('',Country,'',false,true,false);
          
          return result;
                         
       }
      
       Webservice static Distributor_Locator_Output MySalesAssociate(String DistributorId){
         
          list<Distributor_Locator_Output> result = 

DistributerResult('','',DistributorId,false,false,true);
          
         if(!result.isEmpty())
          return result[0];
          else
          return null;
                         
       }        
              
       
       public static list<Distributor_Locator_Output> DistributerResult(String zipCodeInput,String 

Country,String DistributorId,
                                                                                            Boolean 

isZip,Boolean isCountry,Boolean isMyphy)
       {
                     String DisbTypeId = RecordTypeHelper.getRecordTypeId('Account','Distributor');
         
         list<Distributor_Locator_Output> result = new list<Distributor_Locator_Output>();
         list<Account> MatchSales = new list<Account>();
//Territory Number
//MatchSales[0].Territory_Number__c
        if(isZip){
                   map<id,Zip_codes_distributor__c> zcd = new 

map<id,Zip_codes_distributor__c>([select id,name from 
                                                              Zip_codes_distributor__c where name = 

:zipCodeInput]);
                    if(!zcd.isEmpty())
                    {
                        list<County_to_Zip_codes__c> czc = [select 

id,County_Distributor__c,Zip_Codes_Distributor__c from 
                                                                     County_to_Zip_codes__c where 

Zip_Codes_Distributor__c IN :zcd.keyset()];
                        if(!czc.isEmpty())
                        {
                            list<String> CdId = new list<String>();
                            for(County_to_Zip_codes__c cc :czc)
                            {
                                CdId.add(cc.County_Distributor__c);
                            }
                            list<Territory_county__c> tc = [select 

id,County_Distributor__c,territory__c
                                                              from Territory_county__c where 

County_Distributor__c IN :CdId];
                            if(!tc.isEmpty())
                            {
                                list<String> TrId = new list<String>();
                                for(Territory_county__c tt :tc)
                                {
                                    TrId.add(tt.territory__c);
                                }
                                MatchSales = [Select 

id,name,BillingCity,Website,territory__c,BillingState,BillingPostalCode,Distributor_Specialties__c,
                                                       BillingCountry,phone,Toll_free__c,
                                      fax,Territory_Number__c,BillingStreet,Distributor_E_mail__c 
                                                From Account where territory__c IN :TrId and 

RecordTypeId = :DisbTypeId limit 9999];    
                            }
                        }
                    }                                          
         

                                                                                         
                                             
        }else if(isCountry){
          MatchSales = [Select id,name, 

BillingCity,Website,BillingState,BillingPostalCode,Distributor_Specialties__c,BillingCountry,phone,

Toll_free__c,
                                      fax,Territory_Number__c,BillingStreet,Distributor_E_mail__c 

From 
                                                  Account where BillingCountry = :Country and 

RecordTypeId =:DisbTypeId 
                                                  and Organization__c ='Parent' limit 9999];        

    
        }else if(isMyphy){
          MatchSales = [Select id,name, 

BillingCity,Website,BillingState,BillingPostalCode,Distributor_Specialties__c,BillingCountry,phone,

Toll_free__c,
                                      fax,Territory_Number__c,BillingStreet,Distributor_E_mail__c 
                                              From Account where Id = :DistributorId];           
        }
       //     Contact cc;
        //  cc.
          
     if(!MatchSales.isEmpty()){
          for(Account cc :MatchSales)
          {
            Distributor_Locator_Output dd = new Distributor_Locator_Output();
            dd.DistributorId = cc.Id;
            dd.Distributor_name = cc.Name +' - ' + cc.BillingCity +',' +cc.BillingState;
     //     dd.Sales_Associate_First_Name = cc.FirstName;
     //     dd.Sales_Associate_Last_Name = cc.LastName;
            dd.AddressLine1 = cc.BillingStreet;
            dd.City = cc.BillingCity;
            dd.StateOrProvince = cc.BillingState;
            dd.ZipCodeOrPostalCode = cc.BillingPostalCode;
            dd.Country = cc.BillingCountry;
            dd.OfficePhone = cc.Phone;
            dd.SecondaryPhone = cc.Toll_free__c;
            dd.FaxNumber = cc.Fax;
            dd.Email = cc.Distributor_E_mail__c;
            dd.WebsiteUrl = cc.Website;
            dd.Specialty = cc.Distributor_Specialties__c;
            result.add(dd);     
          }
     }
          return result; 
       }
}