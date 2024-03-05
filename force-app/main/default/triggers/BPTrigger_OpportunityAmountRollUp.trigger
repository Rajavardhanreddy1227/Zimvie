trigger BPTrigger_OpportunityAmountRollUp on Opportunity (after insert, after update, before insert, before update) {
    
    
    // Start: Opportunity to Product Sales Summary Association// 
    List<Opportunity> TriggeredOpps = new List<Opportunity> (); 
    Map<String,String> OpportunitySurgeons = new Map<String,String>(); 
    Map<String,Boolean> ActiveUserMap = new Map<String,Boolean>(); 
    Map<String,List<String>> triggeredOpBPOwnerIDMap = new Map <String,List<String>>();
    List<Opportunityshare> oppshare = new List<Opportunityshare>();
    String rectypeName1; 
    string rectypeName2; 
    string rectypeName3; 
    string rectypeName4; 
    string rectypeName5; 
    string rectypeName6; 
    string rectypeName7; 
    string rectypeName8; 
    string rectypeName9; 
    string rectypeName10;
    string rectypeName11; 
    string rectypeName12; 
    string rectypeName13; 
    string rectypeName14; 
    string rectypeName15; 
    string rectypeName16; 
    string rectypeName17; 
    string rectypeName18; 
    string rectypeName19; 
    string rectypeName20; 
    string rectypeName21; 
    string rectypeName22; 
    string rectypeName23; 
    string rectypeName24; 
    string rectypeName25; 
    string rectypeName26; 
    string rectypeName27; 
    string rectypeName28; 
    string rectypeName29; 
    string rectypeName30; 
    string rectypeName31; 
    string rectypeName32; 
    string rectypeName33; 
    string rectypeName34; 
    string rectypeName35; 
    string rectypeName36; 
    string rectypeName37; 
    string rectypeName38; 
    string rectypeName39; 
    string rectypeName40; 
    string rectypeName41; 
    string rectypeName42; 
    string rectypeName43; 
    string rectypeName44; 
    string rectypeName45; 
    string rectypeName46; 
    string rectypeName47; 
    string rectypeName48; 
    string rectypeName49;
    string rectypeName50;
    string rectypeName51; 
    string rectypeName52; 
    string rectypeName53; 
    string rectypeName54; 
    string rectypeName55; 
    string rectypeName56; 
    string rectypeName57; 
    string rectypeName58; 
    string rectypeName59;
    string rectypeName60;
    
    Set<String> UserIds = new Set<String>(); 
    Set<String> BpOwnerIds = new Set<String>(); 
    Set<String> TriggeredOppsID = new Set<String>(); // all opporutnity
    Set<String> TriggerOppsID = new Set<String>(); // only surgeon 

    Date d = date.today().addDays(-4);
    
    Integer currYr = Date.Today().year();
    Date dFirstDayOfYr = Date.newInstance(currYr, 1,1);
    system.debug('check isactive');
    ApexTrigger Atri = [SELECT id, Name, Status FROM ApexTrigger where Name ='BPTrigger_OpportunityAmountRollUp'];
    
    system.debug('check Atri is:');
    
    system.debug('check Atri is :' +Atri.Status);
    // check if trigger is Active
  //  Boolean isActive = Trigger_Settings__c.getInstance('BPTrigger_OpportunityAmountRollUp').Active__c;
    
    String value = 'Active';
    
   // system.debug('check isactive' +isActive);
    
    List<Opportunity> NeedPrdSlsSmryForOpps = new List<Opportunity> ();
    
    If(Atri.Status == value)
    {
        
        for(Opportunity Opps:  [SELECT ID, BP_Target__c, OwnerID, Probability, product_sales_summary__c, NAME,CloseDate,
                                surgeon_Name__c, At_Risk__c, Amount, recordtype.name,Product_Sales_Summary__r.Business_Plan__c,
                                Product_Sales_Summary__r.Business_Plan__r.OwnerID, Account.Territory_Number__c, StageName
                                from Opportunity where id in :trigger.new AND RecordTypeId != '01280000000Q0luAAC'
                               ])
        {
            //IF IOM Request Status Changes... Don't use trigger
            /*Opportunity oldOpty = Trigger.oldMap.get(opps.ID);
            if (Opps.IOM_Request_Status__c != oldOpty.IOM_Request_Status__c) {
                continue;
            }*/
            if (Opps.CloseDate >= dFirstDayOfYr) {
                NeedPrdSlsSmryForOpps.add(Opps);
            }
            
            if(Opps.BP_Target__c == TRUE || (Opps.Probability >= 0.75 && Opps.product_sales_summary__c != null)) {
                system.debug('******'+Opps.Product_Sales_Summary__r.Business_Plan__r.ownerID );
                BpOwnerIds.add( Opps.Product_Sales_Summary__r.Business_Plan__r.ownerID )   ; 
                TriggeredOpps.add(Opps); 
                TriggeredOppsID.add(Opps.id);
                IF(Opps.surgeon_Name__c != null ) {                 
                    TriggerOppsID.add(Opps.id);
                }
            }
        }
        
        if(trigger.isbefore && (TriggeredOpps.size()>0 || NeedPrdSlsSmryForOpps.size() > 0)){
            Set<opportunity> setUpdateOpp = new Set <Opportunity>();
            List<opportunity> listToUpdate = new List <Opportunity> ();
            
            Map<String,Market_Segmentation__c> mapSurgeonIDvsSegmentation = new Map<String,Market_Segmentation__c>();

            // MAP <Territory Acccount ID, MAP <Product Group Name, Product sales Summary record>>
            /* Commenting the automated business plan association functaionlity -------------------------
            Map<id,Map<String,Product_Sales_Summary__c>> mapMasterBP = new Map<id,Map<String,Product_Sales_Summary__c>> ();
            for(Product_Sales_Summary__c pss : [SELECT id, name, Product_Group__c, Business_Plan__r.Territory_Account_Name__c , Business_Plan__r.ownerID
            from Product_Sales_Summary__c 
            where Business_Plan__r.status__c = 'Active']){
            
            Map<String, Product_Sales_Summary__c> tempPSS = new Map<String, Product_Sales_Summary__c>();
            tempPSS.put(pss.Product_Group__c,pss);
            if(mapMasterBP.isEmpty() == TRUE || !mapMasterBP.containsKey(pss.Business_Plan__r.Territory_Account_Name__c)){                                                
            mapMasterBP.put(pss.Business_Plan__r.Territory_Account_Name__c, tempPSS); 
            }else {
            mapMasterBP.get(pss.Business_Plan__r.Territory_Account_Name__c).put(pss.Product_Group__c,pss);
            }    
            }
            */

            Map<String,Map<String,List<Product_Sales_Summary__c>>> mapBPByTerr = BusinessPlanAVPViewController.getAllBusinessPlans();
            System.debug('There are '+mapBPByTerr.size()+' territory records in Business Plan and Product Sales Summary');
            Map<Id, Opportunity> mapOppBPToUpdate = new Map<Id, Opportunity>();
            
            if (NeedPrdSlsSmryForOpps.size() > 0) 
            {
                for (Opportunity o : NeedPrdSlsSmryForOpps)
                {
                    
                    String prdType =  o.RecordType.Name == 'US Hip' ? 'Hips' 
                    : o.RecordType.Name == 'US Knee'? 'Knees' 
                    : o.RecordType.Name == 'US Sports Medicine' ? 'Sports Medicine'  
                    : o.RecordType.Name == 'US Extremities' ? 'Extremities'  
                    : o.RecordType.Name == 'US Foot and Ankle' ? 'Foot & Ankle' 
                    : o.RecordType.Name == 'US Trauma' ? 'Trauma' 
                    : o.RecordType.Name == 'US Cement' ? 'Cement' 
                    : o.RecordType.Name == 'US Early Intervention' ? 'Early Intervention' 
                    : ''; 

                    System.debug('The Product Type is :'+prdType);

                    if (o.AccountId !=null && o.Account.Territory_Number__c != null) 
                    {
                        System.debug('The Territory for Associated Account is '+o.Account.Territory_Number__c);
                        //Get the Product Sales Summary Record
                        
                        List<Product_Sales_Summary__c> prdSalesSmry;
                        //if (mapBPByTerr.get() != null) 
                        if (mapBPByTerr.containsKey(o.Account.Territory_Number__c)) {
                            prdSalesSmry = mapBPByTerr.get(o.Account.Territory_Number__c).get(prdType);
                        }
                        else {
                            System.debug('Product Sales Summary DOES NOT EXIST for Territory: '+ o.Account.Territory_Number__c);
                        }

                        if (prdSalesSmry != null && prdSalesSmry.size() > 0) {
                            System.debug('Product Sales Summary for Territory: '+ o.Account.Territory_Number__c + ' and Product: '+ prdType+ ' is = '+ prdSalesSmry[0].Id);
                        }
                        else {
                            System.debug('Product Sales Summary for Territory: '+ o.Account.Territory_Number__c + ' and Product: '+ prdType+ ' is = NOT AVAILABLE');
                        }
                        if (o.product_sales_summary__c == null && prdSalesSmry != null && prdSalesSmry.size() > 0) 
                        {
                            System.debug('Found Product Sales Summary Record for Opportunity : '+o.Id+ ' and it is '+prdSalesSmry[0].Id);
                            o.product_sales_summary__c = prdSalesSmry[0].Id;
                        }

                        /*if (o.product_sales_summary__c != null && o.StageName == 'Closed Lost')
                        {
                            System.debug('Resetting Product Sales Summary to BLANK/NULL for Opportunity : '+o.Id+ ' as it is '+o.StageName);
                            o.product_sales_summary__c = null;
                        }*/
                    }

                    mapOppBPToUpdate.put(o.id, o);
                    
                }

            }
            //change code here  - bulikify code
            //system.debug('BPownerID*****'+BpOwnerIds);
            
            Map<String,List<String>> groupIDvsMember = new Map<String, List<String>>(); 
            for(GroupMember grp : [Select UserOrGroupId,GroupId from GroupMember where GroupId IN :BpOwnerIds and Group.Type = 'Queue']){
                UserIds.add(grp.UserOrGroupId);
                if(groupIDvsMember.keyset().size()== 0 || !groupIDvsMember.containsKey(grp.GroupId) ){
                    system.debug('InsideIF*****'+grp.UserOrGroupId);
                    List<String> tempgrpmemebers = new List<String>();
                    tempgrpmemebers.add(grp.UserOrGroupId);
                    groupIDvsMember.put(grp.GroupId, tempgrpmemebers); 
                }else{
                    system.debug('InsideElse*****'+grp.UserOrGroupId);
                    groupIDvsMember.get(grp.GroupId).add(grp.UserOrGroupId); 
                }
            }
            
            for(User usr : [SELECT Id,Name,email,IsActive FROM User WHERE ID IN:UserIds AND IsActive=:TRUE]){
                ActiveUserMap.put(usr.Id,usr.IsActive);
            }
            system.debug(' USERS ID SET : '+UserIds.size());
            system.debug('groupIDvsMember*****'+groupIDvsMember);
            
            for(Opportunity Opps: TriggeredOpps){
                
                system.debug('OwnerID'+Opps.Product_Sales_Summary__r.Business_Plan__r.OwnerID );
                If(Opps.OwnerID != Opps.Product_Sales_Summary__r.Business_Plan__r.OwnerID && Opps.Product_Sales_Summary__r.Business_Plan__r.OwnerID != null){
                    String BPOwner = String.valueOf(Opps.Product_Sales_Summary__r.Business_Plan__r.OwnerID) ; 
                    List<String> grpmemebers = new List<String>(); 
                    if(BPOwner.startsWith('00G') == TRUE && groupIDvsMember.containsKey(BPOwner)){
                        system.debug('Inside IF BPOwner*****'+BPOwner);
                        for(String userid : groupIDvsMember.get(BPOwner)){
                            system.debug('BPOwner*****'+userid);
                            if(userid != Opps.OwnerID){
                                grpmemebers.add(userid); 
                            }                        
                        }                                  
                    }else{
                        system.debug('Inside ELSE BPOwner*****'+BPOwner);
                        grpmemebers.add(BPOwner); 
                    }
                    triggeredOpBPOwnerIDMap.put(Opps.id, grpmemebers);
                }
                OpportunitySurgeons.put(Opps.surgeon_Name__c, Opps.recordtype.name ); 
                system.debug('Opportunity Surgeon'+Opps.surgeon_Name__c+'  ---  '+Opps.recordtype.name );
            }
            
            //get the market segmentation data to associate with the Opportunity
            for(Market_Segmentation__c mkt: [SELECT id, Product_Group__c, Segementation__c, Aligned_Team__c, Surgeon_Name__c 
                                             from Market_Segmentation__c
                                             where   Surgeon_Name__c IN :OpportunitySurgeons.keyset()])
            {
                String rectypeName ; 
                rectypeName = mkt.Product_Group__c == 'Hips' ? 'US Hip' 
                            : mkt.Product_Group__c == 'Knees'? 'US Knee' 
                            : mkt.Product_Group__c == 'Sports Medicine' ? 'US Sports Medicine'  
                            : mkt.Product_Group__c == 'Extremities' ? 'US Extremities'  
                            : mkt.Product_Group__c == 'Foot & Ankle' ? 'US Foot and Ankle' 
                            : mkt.Product_Group__c == 'Trauma' ? 'US Trauma' 
                            : mkt.Product_Group__c == 'Cement' ? 'US Cement' 
                            : ''; 
                system.debug('Opportunity Recordtype Name --> '+rectypeName );
                if(rectypeName == OpportunitySurgeons.get(mkt.Surgeon_Name__c)){
                    mapSurgeonIDvsSegmentation.put(mkt.Surgeon_Name__c, mkt);
                    system.debug('mkt aligned Team --> '+mkt.Aligned_Team__c );
                }                
            }

            if(trigger.isinsert || trigger.isupdate){
                for(Opportunity c :trigger.new) {
                    if (mapOppBPToUpdate.containsKey(c.id) )
                    {
                        String sId = c.id;
                        if (c.Product_Sales_Summary__c != null) {
                        System.debug('Triggered Oppty : Product Sales Summary = '+c.Product_Sales_Summary__c + ' and id is : '+c.Id);
                        }
                        else {
                        System.debug('Triggered Oppty : Product Sales Summary = null');
                        }
                        
                        System.debug('Current Value of Prd Sales Smry : '+c.Product_Sales_Summary__c);
                        System.debug('Old Value of Prd Sales Smry : '+trigger.oldMap.get(c.id).Product_Sales_Summary__c);
                        if (c.StageName != 'Closed Lost') {
                            //Blank Update allowed if Old value is being wiped out
                            if (trigger.isupdate && 
                                (c.Product_Sales_Summary__c == null)
                            && trigger.oldMap.get(sId).Product_Sales_Summary__c != null
                               )
                            {
                                System.debug('Setting Product Sales Summary = null');
                                c.Product_Sales_Summary__c = null;
                            }
                            else if (c.Product_Sales_Summary__c == null ||
                             (c.Product_Sales_Summary__c != null && c.Product_Sales_Summary__c != mapOppBPToUpdate.get(c.id).Product_Sales_Summary__c)) {
                                
                                c.Product_Sales_Summary__c = mapOppBPToUpdate.get(c.id).Product_Sales_Summary__c;
                            }
                        }
                        else {
                            c.Product_Sales_Summary__c = null;
                        }
                    }
                    if(TriggeredOppsID.contains(c.id) && (c.Product_Sales_Summary__c != null || c.BP_Target__c == true)){
                        // this to make sure all the at risk amount is negative   
                        IF(c.At_Risk__c == TRUE && c.amount > 0 ){
                            c.amount = - c.amount; 
                        }    
                        IF(c.Probability == 100 &&  c.BP_Target__c == FALSE && c.product_sales_summary__c != null ){
                            system.debug('if probability == 100 %-->'+  c.Probability);
                            c.BP_Target__c = TRUE ; 
                        }

                        //update segmentation and team information
                        If(mapSurgeonIDvsSegmentation.size()> 0 && mapSurgeonIDvsSegmentation.containskey(c.surgeon_Name__c)){
                            c.Avalanche_Segmentation__c = mapSurgeonIDvsSegmentation.get(c.surgeon_Name__c).Segementation__c; 
                            c.Team_Name__c = mapSurgeonIDvsSegmentation.get(c.surgeon_Name__c).Aligned_Team__c ; 
                        }
                        
                        if(!triggeredOpBPOwnerIDMap.isEmpty() && triggeredOpBPOwnerIDMap.containsKey(c.id)){
                            system.debug('Business plan owner---->>>'+ triggeredOpBPOwnerIDMap.get(c.id));
                            for(String ownerstr : triggeredOpBPOwnerIDMap.get(c.id))
                            {
                                if(ActiveUserMap.containsKey(ownerstr)){
                                    Opportunityshare tempshare = new Opportunityshare();
                                    tempshare.OpportunityId = c.id;
                                    tempshare.UserOrGroupId = ownerstr ; 
                                    tempshare.OpportunityAccessLevel = 'Edit';
                                    tempshare.RowCause = Schema.Opportunityshare.RowCause.Manual; 
                                    oppshare.add(tempshare);
                                }
                            }
                        }
                        /* Commenting this section 10/2/2019 ---------------- 
                        //Get Produt sales summary and associate with the opportunity    
                        If(c.BP_Target__c == TRUE && c.Product_Sales_Summary__c ==null && c.Territory_Name__c != null){
                        c.Product_Sales_Summary__c = mapMasterBP.get(c.Territory_Name__c).get(c.BP_Opportunity_Product_Group__c).id;
                        }  ******/ 
                        
                        // Added per Michele's Comment 7/2/19 - if the stage is Closed Lost then Uncheck the BP Target 
                        else if (trigger.isupdate 
                                 && trigger.oldMap.get(c.id).StageName != trigger.newMap.get(c.Id).StageName 
                                 && trigger.newMap.get(c.Id).StageName  == 'Closed Lost'
                                 && c.BP_Target__c == TRUE ) {
                                     c.BP_Target__c = FALSE;
                                     c.Product_Sales_Summary__c = null;
                                 }
                        
                        // this section has been commented out as per Michele's suggestion on 7/2/19
                        // If the BP Target is false - it should still attach to the BP but will not in included in the Opportunity Risk calculations
                        /********************************************************************************** 
                        else if (trigger.isupdate && trigger.oldMap.get(c.id).BP_Target__c != trigger.newMap.get(c.Id).BP_Target__c && c.BP_Target__c == FALSE ){
                        c.Product_Sales_Summary__c = null;
                        }
                        ************************************************************************************/
                    }
                }            
            }    
            
        }
        if(!oppshare.IsEmpty()){
            system.debug('Share List--> '+oppshare);
            insert oppshare ; 
        }
        // END : Opportunity to Product Sales Summary Association// 

        // Start Automatic Assignment for Product Sales Summary Record
        
        
        
        // START: Product Sales Summary Opportunity & Risk Update section// 
        if(trigger.isafter ){
            //System.debug('Setting Product Sales Summary');
            Set<Id> setProductSalesIds=new Set<Id>();
            //get sales summary 
            for(Opportunity c:Trigger.new){
                
                system.debug('Triggered Oppo-->>'+c.Name);
                if (c.Product_Sales_Summary__c != null ){
                    setProductSalesIds.add(c.Product_Sales_Summary__c);                           
                }else if (trigger.isupdate && 
                          trigger.oldMap.get(c.id).Product_Sales_Summary__c!= null && 
                          trigger.oldMap.get(c.id).Product_Sales_Summary__c != trigger.newMap.get(c.id).Product_Sales_Summary__c)  {
                              setProductSalesIds.add(trigger.oldMap.get(c.id).Product_Sales_Summary__c);                
                          } 
                
            }
            system.debug('Triggered product sales IDs-->>'+setProductSalesIds);
            if(setProductSalesIds.size() > 0 ){               
                MAP<String,Product_Sales_Summary__c> mapProductSalesUpdate = new MAP<String,Product_Sales_Summary__c>();
                Set<String> setOpportunityPSSID = new Set<String> ();
                Set<String> setRiskPSSID = new Set<String> ();
                for(AggregateResult result:[Select Product_Sales_Summary__c, SUM(Next_Year_Estimated_Revenue__c) From Opportunity 
                                            WHERE Product_Sales_Summary__c IN :setProductSalesIds 
                                            AND BP_Target__c = TRUE
                                            AND At_Risk__c = FALSE
                                            AND Next_Year_Estimated_Revenue__c != null
                                            GROUP BY Product_Sales_Summary__c])
                {
                    setOpportunityPSSID.add(String.ValueOf(result.get('Product_Sales_Summary__c')));
                    IF(mapProductSalesUpdate.get(String.ValueOf(result.get('Product_Sales_Summary__c'))) == null) {            
                        Product_Sales_Summary__c pss = new Product_Sales_Summary__c(id=String.ValueOf(result.get('Product_Sales_Summary__c')));
                        system.debug('Product Sales Summary --->>> '+String.ValueOf(result.get('Product_Sales_Summary__c')));
                        system.debug('AggregateResult-->>'+result);
                        pss.Opportunities__c = Decimal.ValueOf(String.ValueOf(result.get('expr0')));
                        mapProductSalesUpdate.put(String.ValueOf(result.get('Product_Sales_Summary__c')),pss );
                    }
                    else
                    {
                        mapProductSalesUpdate.get(String.ValueOf(result.get('Product_Sales_Summary__c'))).Opportunities__c = Decimal.ValueOf(String.ValueOf(result.get('expr0')));
                    }
                }
                
                for(AggregateResult result:[Select Product_Sales_Summary__c, SUM(Next_Year_Estimated_Revenue__c) From Opportunity 
                                            WHERE Product_Sales_Summary__c IN :setProductSalesIds 
                                            AND BP_Target__c = TRUE
                                            AND At_Risk__c = TRUE
                                            AND Next_Year_Estimated_Revenue__c != null
                                            GROUP BY Product_Sales_Summary__c])
                {
                    setRiskPSSID.add(String.ValueOf(result.get('Product_Sales_Summary__c')));
                    system.debug('AggregateResult Risk-->>'+result);
                    system.debug('Product Sales Summary --->>> '+String.ValueOf(result.get('Product_Sales_Summary__c')));
                    IF(mapProductSalesUpdate.get(String.ValueOf(result.get('Product_Sales_Summary__c'))) == null) {            
                        Product_Sales_Summary__c pss = new Product_Sales_Summary__c(id=String.ValueOf(result.get('Product_Sales_Summary__c')));
                        pss.Risks__c =  Decimal.ValueOf(String.ValueOf(result.get('expr0')));
                        mapProductSalesUpdate.put(String.ValueOf(result.get('Product_Sales_Summary__c')),pss );
                    }
                    else{
                        mapProductSalesUpdate.get(String.ValueOf(result.get('Product_Sales_Summary__c'))).Risks__c =  Decimal.ValueOf(String.ValueOf(result.get('expr0')));
                    } 
                    
                }
                for(id pssid : setProductSalesIds){
                    if(mapProductSalesUpdate.containskey(pssid)){
                        if(setOpportunityPSSID.contains(pssid) && !setRiskPSSID.contains(pssid)){
                            mapProductSalesUpdate.get(pssid).Risks__c = 0;
                        }else if(setRiskPSSID.contains(pssid) && !setOpportunityPSSID.contains(pssid)){
                            mapProductSalesUpdate.get(pssid).Opportunities__c = 0;
                        }
                    }else{
                        system.debug('Inside else'+pssid);
                        Product_Sales_Summary__c pss = new Product_Sales_Summary__c(id=pssid);
                        pss.Risks__c = 0;
                        pss.Opportunities__c = 0;
                        mapProductSalesUpdate.put(pssid, pss);
                    }
                }
                if(!mapProductSalesUpdate.isEmpty() ){   
                    update mapProductSalesUpdate.values();
                }            
            }
        }
    }
    
    // END: Product Sales Summary Opportunity & Risk Update section// 
}// END: Trigger code