public with sharing class SurgeonPortalExtension 
{           
    private final GPL_Profile__c request;    
    public List<GPL_Location__c> gplLocations{get{return gplLocations;} set;}
    public SurgeonPortalExtension(){}
    public SurgeonPortalExtension(ApexPages.StandardController controller)
    {                      
        request=(GPL_Profile__c)controller.getRecord();
        String surgeonId=Apexpages.currentPage().getParameters().get('surgeonId');
        if(surgeonId!=null)
            {
                GPLProfileId=loadSurgeonData(surgeonId);
                system.debug('GPL Profile Id='+GPLProfileId);
            }
            
        loadLocations();
        
    }
    
   private void loadLocations()
   {
       gplLocations = [Select Id, Name, Name__c, City__c, State__c, PostalCode__c, Country__c from GPL_Location__c where GPL_Profile__c =: request.id];   
   }
    public Id GPLProfileId 
    {       
        get;
        set;    
    }  

    public Id SelectedLocationId 
    {       
        get;
        set;    
    }
    
    public Id loadSurgeonData(String surgeonId)
    {
        Id gplId=null;
                        
        for(Account surgeonPersonAccount:[select Id,IsPersonAccount from Account where PersonContactId=:surgeonId limit 1])
        {
                if(surgeonPersonAccount.IsPersonAccount)
                {
                    surgeonId=surgeonPersonAccount.Id;                  
                }
        }
        
        system.debug('surgeonId='+surgeonId);
        if(surgeonId.length()==18)surgeonId=surgeonId.substring(0,15); 
            
        for(GPL_Profile__c gplProfile:[select Id from GPL_Profile__c where ParentId__c=:surgeonId limit 1])
        {
            gplId=gplProfile.Id;
        }           
        return gplId;       
                
    }
     
    public PageReference doAction()
    {
        if(GPLProfileId!=null)
        {
            PageReference pr = new PageReference('/apex/SurgeonPortalView?id='+GPLProfileId);
            pr.setRedirect(true);
            return pr;
        }
        else
        {
            PageReference pr = new PageReference('/apex/SurgeonPortalError');
            pr.setRedirect(true);
            return pr;
        }       
    }
    
    public PageReference UploadPhoto()
    {                
        //PageReference pr = new PageReference('/p/attach/NoteAttach?pid='+request.Id+'&retURL=%2Fservlet%2Fservlet.Integration%3Flid=01NL0000000CeQH%26eid='+request.Id+'%26ic=1%26autoMapValues=1');        
        PageReference pr = Page.Surgeon_portal_PhotoPage;
        pr.getParameters().put('id',request.Id);        
        pr.setRedirect(true);
        return pr;
                    
    }
    
    public string fileName{
        get;set;    
    }  
      
    public Blob fileBody{
        get;set;    
    } 
    public PageReference UploadFile()  
    {  
        PageReference pr;  
        if(fileBody != null && fileName != null)  
        {
          GPL_Profile__c gplRequest=[select Picture_Id__c,Id from GPL_Profile__c where Id=:request.Id];  
          Attachment myAttachment  = new Attachment();  
          myAttachment.Body = fileBody;  
          myAttachment.Name = fileName;  
          myAttachment.ParentId = gplRequest.Id;            
          insert myAttachment;
          
          gplRequest.Picture_Id__c = myAttachment.Id;
          update gplRequest;
          
          pr = new PageReference('/apex/SurgeonPortalView?id='+gplRequest.Id);
          pr.setRedirect(true);
          return pr;           
        }  
        return null;  
    }
    
   //Open record in edit mode.
    public PageReference edit()
    {
        /****************************************************************************************************
        Purpose: edit method is used on Edit button to return SurgeonPortalEdit visualforce page
        which is displayed on visualforce page                      
        Parameters: None
        Returns: This property returns a PageReference.
        ******************************************************************************************************/        
        String returnPage;
        returnPage=ApexPages.currentPage().getParameters().get('returnURL');        
        return new PageReference(returnPage);        
    }
      
    public PageReference save()
    {
        GPL_Profile__c gplRequest=[select Id,GPL_Physician_Locator__c,Inactive__c from GPL_Profile__c where Id=:request.Id limit 1];
        if(gplRequest.GPL_Physician_Locator__c == False){
        request.GPL_Physician_Locator__c = True;
        request.Inactive__c=False;
        }
        String returnPage;
        try{                
        update request;
        }
        catch(Exception e){
             ApexPages.addMessages(e);
             return null;
        } 
        returnPage=ApexPages.currentPage().getParameters().get('returnURL');
        return new PageReference(returnPage);                   
    }
        
    public PageReference newLocation()
    {          
      GPL_Profile__c gplRequest=[select Name from GPL_Profile__c where Id=:request.Id];
      //return new Pagereference('/apex/SurgeonPortalDetailEdit?CF00NL0000000KouT_lkid='+gplRequest.Id+'&CF00NL0000000KouT='+gplRequest.Name+'&sfdc.override=1');
      return new Pagereference('/apex/SurgeonPortalDetailEdit?CF00NC0000005FaHm_lkid='+gplRequest.Id+'&CF00NC0000005FaHm='+gplRequest.Name+'&sfdc.override=1');
    }
    
   public void deleteLocation()
   {
       
      if (SelectedLocationId == null) {
          return;
      }
      
      GPL_Location__c tobeDeleted = null;
      for(GPL_Location__c gpl : gplLocations)
       if (gpl.Id == SelectedLocationId) {
          tobeDeleted = gpl;
          break;
       }
      
      if (tobeDeleted != null) {
       Delete tobeDeleted;
     }
     loadLocations();
     /*
     String returnPage;
     returnPage='/apex/SurgeonPortalView?id='+request.id;
     PageReference pr = new PageReference(returnPage);
     return pr;*/
   } 
   
   /*
   public boolean checkRequiredFieldsSave(){
   
   String message='';      
        Boolean success=true;
        
        if(request.Location_Count__c==1)
        {
            message='You Cannot delete this Practice Locations, as atleast One Practice Location for a Surgeon Must Exist';
            success=false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
            //return success;
        }
        return success;
   
   }*/  
    public String getLt(){
        return '<';
    }   
    public String getGt(){
        return '>';
    }     
}