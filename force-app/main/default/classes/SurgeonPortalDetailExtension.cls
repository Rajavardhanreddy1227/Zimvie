public with sharing class SurgeonPortalDetailExtension{
    private GPL_Location__c request;
    public string url{get;set;}
    public SurgeonPortalDetailExtension(ApexPages.StandardController controller)
    {                   
        request=(GPL_Location__c)controller.getRecord();
        
    }
    
    public PageReference edit()
    {               
        String returnPage;
        returnPage=ApexPages.currentPage().getParameters().get('returnURL');        
        return new PageReference(returnPage);        
    }
    public PageReference save()
    {
      //if(!checkRequiredFieldsSave()){
      //return Null;
      //}
      String returnPage;
      system.debug('The request ID is:'+request.id);
      if(request.id != null){
        try{
        system.debug('The request ID is:'+request.id);
          update request;
        }
        catch(Exception e){
             ApexPages.addMessages(e);
             return null;
        }                       
      }
      else{
      system.debug('The request without ID is:');
        try{
        system.debug('The request without2 ID is:');
          insert request;
        }
          catch(Exception e){
             ApexPages.addMessages(e);
             return null;
        }         
      }    
      returnPage='/apex/SurgeonPortalView?id='+request.Gpl_Profile__c;

      PageReference pr = new PageReference(returnPage);
      return pr;                      
    }
    /*
    public PageReference saveAndNew()
    {
    if(request.id != null){
          update request;                       
      }
      else{
          insert request;         
      }
      
      string s = '/' + ('' + request.get('Id')).subString(0, 3) + '/e?';
      return new Pagereference(s+'CF00Nc0000000GX8F_lkid='+request.Gpl_Profile__c);   
      //return new Pagereference('/apex/SurgeonPortalDetailEdit?CF00Nc0000000GX8F_lkid='+request.Gpl_Profile__c+'&save_new=1&sfdc.override=1');
    }
    */
    public PageReference doClose()
    {    
        PageReference pr = new PageReference(ApexPages.currentPage().getParameters().get('returnURL'));
        pr.setRedirect(true);
        return pr;
    }
    public String getLt(){
        return '<';
    }   
    public String getGt(){
        return '>';
    }   
    
    public boolean checkRequiredFieldsSave(){
    String message='';      
    Boolean success=true;
        
        if(request.Fax__c!=Null)
        {
            String Fax = String.valueOf(request.Fax__c);            
            //Pattern MyPattern = Pattern.Compile('^[0-9]{10}');
            Pattern Pattern1 = Pattern.Compile('\\D*?(\\d\\D*?){10}');
            Pattern Pattern2 = Pattern.Compile('^\\+(?:[0-9] ?){6,14}[0-9]$');
            Matcher Matcher1 = Pattern1.matcher(Fax);
            Matcher Matcher2 = Pattern2.matcher(Fax);
            boolean check1 = Matcher1.matches();
            boolean check2 = Matcher2.matches();         
                       
            if(check1 == False || check2==False){
            message='Fax number must be a valid US or International phone number. (###)###-#### or +## ##### #####';
            success=false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
            }
            //return success;
        }       
        
        if(request.Phone__c!=Null)
        {
            String Phone = String.valueOf(request.Phone__c);
            Integer PhoneLength = Phone.length();
            
            //Pattern MyPattern = Pattern.Compile('^[0-9]{10}');
            Pattern Pattern1 = Pattern.Compile('\\D*?(\\d\\D*?){10}');
            Pattern Pattern2 = Pattern.Compile('^\\+(?:[0-9] ?){6,14}[0-9]$');
            Matcher Matcher1 = Pattern1.matcher(Phone);
            Matcher Matcher2 = Pattern2.matcher(Phone);
            boolean check1 = Matcher1.matches();
            boolean check2 = Matcher2.matches();         
                       
            if(check1 == False || check2==False){
            message='Phone number must be a valid US or International phone number. (###)###-#### or +## ##### #####';
            success=false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
            }
        }
        /*
         if(request.PostalCode__c!=Null)
        {
            String Zip = String.valueOf(request.PostalCode__c);
            Integer PhoneLength = Zip.length();
            
            Pattern MyPattern = Pattern.Compile('^[0-9]{6}');
            Matcher MyMatcher = MyPattern.matcher(Zip);
            boolean check = MyMatcher.matches();                   
            
            
            if((PhoneLength != 6)||(check == False)){
            message='The postal Code entered is not in the correct Format. You are only allowed to save 6 Digits, and no alpahbets';
            success=false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
            }            
        }
        */
        return success;
        }
       
        
    
    
}