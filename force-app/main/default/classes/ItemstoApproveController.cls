public class ItemstoApproveController {
    
    ApexPages.standardController stdController= null;
    public ItemstoApproveController(ApexPages.StandardController controller) {
        stdController=controller;
    }
    public opportunity Objectopportunity {get; set;}
    public List<opportunity> lstopportunityapprove {get; set;}
    ID Oppyid;
    Set<ID> oppyids=new Set<ID>();
  
    public class item_wrapper {
        public item_wrapper(id id,string name,string objtype,String DateSubmited,string tcmeetingcomments, id approvalid ) {
            this.id = id;
            this.name = name;
            this.objtype = objtype;
            this.DateSubmited = DateSubmited;
            this.tcmeetingcomments=tcmeetingcomments;
            this.approvalid =approvalid ;
        }
        public id id { get; set; }
        public string name { get; set; }
        public string objtype { get; set; }
        public String DateSubmited { get; set; }
        public string tcmeetingcomments{ get; set; }
        public id approvalid { get; set; }
      
    }
  
    public list<item_wrapper> items_to_approve { get; set; }
  
    public ItemstoApproveController() {
        items_to_approve = new list<item_wrapper>();
      
        map<id,ProcessInstanceWorkItem> mpaPIWIdToPIW = new map<id,ProcessInstanceWorkItem>();
        list<ProcessInstanceWorkItem> lstPIWI = [SELECT processinstance.targetobjectid,CreatedDate ,processinstance.targetobject.name,ProcessInstance.TargetObject.type 
                                                FROM processinstanceworkitem 
                                                WHERE actorid = :userinfo.getuserid() 
                                                AND ProcessInstance.TargetObject.type = 'Business_plan__c'
                                                ORDER BY CreatedDate Desc];
        system.debug('---lstPIWI---'+lstPIWI);
        system.debug('---lstPIWI-size()---'+lstPIWI.size());
        
        if(!lstPIWI.isEmpty()){
            for(ProcessInstanceWorkItem item: lstPIWI) {
                oppyids.add(item.processinstance.targetobjectid);
                if(!mpaPIWIdToPIW.containsKey(item.processinstance.targetobjectid)){
                    mpaPIWIdToPIW.put(item.processinstance.targetobjectid,item);
                }
            }
        }
      
        map<id,Opportunity> mapoptyIdtoMeetingnotes = new map<id,Opportunity>();
        
        system.debug('---oppyids---'+oppyids);
        system.debug('---oppyids-size()---'+oppyids.size());
      
        if(oppyids.size()>0){
            lstopportunityapprove=[select id,Owner.name,name,stagename,Notes__c  from Opportunity where id in : oppyids];
            if(!lstopportunityapprove.isEmpty()){
                for(opportunity objoppy:lstopportunityapprove){
                    mapoptyIdtoMeetingnotes.put(objoppy.id,objoppy);
                }
            }
        }
        if(!lstPIWI.isEmpty()){
          
            for(ProcessInstanceWorkItem item: mpaPIWIdToPIW.values()) {
                String dateTimeValue = item.CreatedDate.format('MM/dd/yyyy hh:mm a');
                system.debug(dateTimeValue +'Debug2 dateTimeValue ');
                if(item.processinstance.TargetObject.type == 'Opportunity'){
                    system.debug(item.processinstance.targetobjectid +'Debug2 dateTimeValue ');

                    items_to_approve.add(new item_wrapper(item.processinstance.targetobjectid,item.processinstance.targetobject.name,item.processinstance.TargetObject.type,dateTimeValue ,mapoptyIdtoMeetingnotes.get(item.processinstance.targetobjectid).Notes__c,item.id ));
                }else{
                   system.debug(item.processinstance.targetobjectid +'Debug2 dateTimeValue ');
                    String sObjName = item.processinstance.targetobjectid.getSObjectType().getDescribe().getLabel(); 
                                                           system.debug(sObjName +'sObjNameValue ');
                    items_to_approve.add(new item_wrapper(item.processinstance.targetobjectid,item.processinstance.targetobject.name,sObjName ,dateTimeValue ,'',item.id )); 
                }
            }
        }
    }   
    public  static String ApproveRejectnavigation() {
        String url=''; 
        string myParam = apexpages.currentpage().getparameters().get('myParam');
        url='https://'+ System.URL.getSalesforceBaseUrl().getHost() + 
            '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + myParam ;     
      
        return url; 
      
    }
    public  static String REASSIGNnavigation() {
        String url=''; 
        string myParam = apexpages.currentpage().getparameters().get('myParam');
        url='https://'+ System.URL.getSalesforceBaseUrl().getHost()+'/'+ myParam +'/e?et=REASSIGN';     
        return url; 
      
    }
    
    
  
}