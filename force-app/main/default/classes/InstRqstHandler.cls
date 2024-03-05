public with sharing class InstRqstHandler {
    public static boolean isRunning = false;
    public InstRqstHandler() {

    }

    public static void onBeforeInsertUpdate(List<Instrument_Request__c> irList){
        List<Opportunity> updatedOppList = new List<Opportunity>();
        Set<Id> terrIds = new Set<Id>();
        Map<Id,Id> oppTerrMap = new Map<Id,String>();
        System.debug('In InstRqstHandler - onBeforeInsertUpdate : No of Instrument Records = '+irList.size());  

        for (Instrument_Request__c ir: irList){
            if((ir.SNAP_Kit_Nbr__c == null || String.isBlank(ir.SNAP_Kit_Nbr__c) 
                && ir.SNAP_KIT_ID__c != null && String.isNotBlank(ir.SNAP_KIT_ID__c))){
                ir.SNAP_Kit_Nbr__c = ir.SNAP_KIT_ID__c.right(ir.SNAP_KIT_ID__c.length()-19);
            }
        }        
    }   

    public static void onAfterInsertUpdate(List<Instrument_Request__c> irList, Map<Id,Instrument_Request__c> irMap){

        if (InstRqstHandler.isRunning)
        {
            return;
        }

        InstRqstHandler.isRunning = false;

        Set<Id> oppIds = new Set<Id>();       
        Set<String> kitIds = new Set<String>();
        Map<Id, Set<String>> oppStatusMap = new Map<Id, Set<String>>();
        /*
            oppStatusMap => Set <Status String>, Sent, Shipped etc.
        */
        System.debug('In InstRqstHandler - onAfterInsertUpdate : No of IRs = '+irList.size());
        for (Instrument_Request__c ir: irList){
            if (ir.Opportunity__c != null)
            {
                oppIds.add(ir.Opportunity__c);
            }
            if (ir.SNAP_Kit_Nbr__c != null)
            {
                kitIds.add(ir.SNAP_Kit_Nbr__c);
            }
        }

        // May Need to Fetch all Instrument Requests... for the Opportunity and then create Status list
        List<Opportunity> oppListToUpdate = [Select Id, Name, IOM_Request_Status__c from Opportunity where Id in :oppIds];

        List<Instrument_Request__c> lstIRs = [Select Id, Opportunity__c, Status__c, Record_Number__c,SNAP_Kit_Nbr__c from Instrument_Request__c where Opportunity__c IN :oppIds order by Opportunity__c asc, Status__c];
        List<Instrument_Request__c> lstIRsByKitIds = [Select Id, Opportunity__c, Status__c, Record_Number__c,SNAP_Kit_Nbr__c from Instrument_Request__c where SNAP_Kit_Nbr__c IN :kitIds order by SNAP_Kit_Nbr__c, Opportunity__c asc];

        System.debug('It found '+lstIRs.size()+' instrument requests for Oppty : '+oppIds);

        Integer i = 1;
        String prevIRSnapKitNbr = '';
        Set<Instrument_Request__c> lstIRToUpdateForOrder = new Set<Instrument_Request__c>();

        for (Instrument_Request__c ir: lstIRs){
            if (ir.Opportunity__c != null)
            {
                if (oppStatusMap.containsKey(ir.Opportunity__c)) {
                    oppStatusMap.get(ir.Opportunity__c).add(ir.Status__c);
                }
                else {   
                    Set<String> st = new Set<String>();
                    st.add(ir.Status__c);
                    oppStatusMap.put(ir.Opportunity__c, st);
                }
            }
        }
        for (Instrument_Request__c ir: lstIRsByKitIds){

            if (ir.SNAP_Kit_Nbr__c != prevIRSnapKitNbr)
            {
                i = 1;
            }
            else 
            {
                i++;
            }

            if (ir.Record_Number__c != i)
            {
                System.debug('IR '+ir.SNAP_Kit_Nbr__c + ' Oppty: '+ir.Opportunity__c+ ' order does not match : '+ ir.Record_Number__c + ' vs '+ i);
                ir.Record_Number__c = i;
                lstIRToUpdateForOrder.add(ir);
            }

            prevIRSnapKitNbr = ir.SNAP_Kit_Nbr__c;
        }

        //System.debug(oppStatusMap);
		List<Opportunity> finalListOfOppToUpdate = new List<Opportunity>();
        for (Opportunity o: oppListToUpdate) {            
            String strOppStatus = '';
            for (String s : oppStatusMap.get(o.Id))
            {
                strOppStatus += s + ';';
            }
            if (o.IOM_Request_Status__c != strOppStatus) {
                System.debug('IOM Status is not same... '+ o.IOM_Request_Status__c + ' vs '+ strOppStatus + '. It will be updated for Opp: '+o.Id);
            	o.IOM_Request_Status__c = strOppStatus;
                finalListOfOppToUpdate.add(o);
       		}
            else {
                System.debug('IOM Status is same... '+ o.IOM_Request_Status__c + ' vs '+ strOppStatus + '. It will NOT be updated for Opp: '+o.Id);
            }
           
        }
        
        if(!finalListOfOppToUpdate.isEmpty()){            
            update oppListToUpdate;
        }

        System.debug('Found IR Reordering needed for '+lstIRToUpdateForOrder.size() + ' records');
        if (!lstIRToUpdateForOrder.isEmpty()){  
            //InstRqstHandler.isRunning = true; 
            //List<Instrument_Request__c> lstIRs =  new List<Instrument_Request__c>(lstIRToUpdateForOrder); 
            update (new List<Instrument_Request__c>(lstIRToUpdateForOrder));
        }
    }
}