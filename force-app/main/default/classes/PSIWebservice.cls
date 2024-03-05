global class PSIWebservice
{
    global class PSISearchCriteria
    {       
        WebService String NPI;            
    }
    global class PSISurgeonOutput
    {
        WebService String Flag;
        WebService Account Surgeon;
    }
WebService  static PSISurgeonOutput SearchSurgeonInfo(PSISearchCriteria criteria)
    {
        if(criteria.NPI==''){
            PSISurgeonOutput surgeonInfo = new PSISurgeonOutput();
            surgeonInfo.Flag='-1';
            system.debug('When NPI is blank, Flag='+surgeonInfo.Flag);
            return surgeonInfo;
        }
        
        String query = buildQueryAccount(criteria);        
        list<PSISurgeonOutput> result = runQuery(query); 
         
        if(!result.isEmpty()){
        system.debug('the flag status is: '+result[0]);
        return result[0];
        }
        else
        { 
        PSISurgeonOutput surgeonInfo = new PSISurgeonOutput();       
        system.debug('the flag status is: '+'0');         
        surgeonInfo.Flag='0';       
        return surgeonInfo;
        }   
    }
   
    public static String buildQueryAccount(PSISearchCriteria criteria)
    {
        
        string query='Select FirstName,LastName,Middle_name__c,Salutation,Phone,PersonMailingStreet,PersonMailingCity,PersonMailingState,PersonMailingCountry,PersonMailingPostalCode from Account where isPersonAccount=true and NPI__c=\''+String.escapeSingleQuotes(criteria.NPI)+'\' limit 1';
        return query;
    }
    
    
public static list<PSISurgeonOutput> runQuery(String query)
    {
        list<Account> Surgeons = Database.query(query);
        list<PSISurgeonOutput> result=new list<PSISurgeonOutput>();
        
        try{    
        if(Surgeons.size()>0 ){
        PSISurgeonOutput so = new PSISurgeonOutput();
        for (Account Surgeon: Surgeons)
            {                                      
             so.Flag='1';
             so.Surgeon=Surgeon;  
             result.add(so);
            }       
        }        
       }catch (exception e){system.debug('Exception='+e);}
      return result;  
    }
    
}