trigger AccountBeforeInsertUpdate on Account (before insert, before update){

integer i,k;
    string address3 = '';  
    
    for(Account a: trigger.new) {
     	//Modified by RA: Code commented because now only Physician record Type is in Use
        // if(a.RecordTypeId == '012800000002C4gAAE' || a.RecordTypeId == '012800000003YRmAAM' || a.RecordTypeId == '012800000003YRcAAM' || a.RecordTypeId == '012800000003YRrAAM' || a.RecordTypeId == '012800000003YRhAAM' || a.RecordTypeId == '012800000003YRnAAM')
     if(a.RecordTypeId == '012800000002C4gAAE')
       {
        String[] myStrings = new String[10];
        if(a.PersonMailingStreet != NULL){
           
            myStrings = a.PersonMailingStreet.split('\n');
            a.Office_Building_Floor_Department__c = '';
            a.Office_Street_PO_Box__c = '';
            a.Office_Suite__c = '';
           
            k=mystrings.size();
            system.debug(k);
            system.debug(a.PersonMailingStreet);
        
            if(k > 2){
                for(i = 2; i < k; i++){
                    if(myStrings[i] == '')
                        break;
                    else
                        address3 += myStrings[i].trim()+' '; 
                    }
              a.Office_Street_PO_Box__c = address3;
              a.Office_Suite__c = myStrings[0];
              a.Office_Building_Floor_Department__c = myStrings[1];
             
         address3 = '';
            }
            else if(k == 2) 
            {
                
                a.Office_Building_Floor_Department__c = myStrings[1];
                a.Office_Suite__c = myStrings[0];
                
            }
            
            else if(k == 1) a.Office_Suite__c = myStrings[0];
 
            
       }
     
     if(a.PersonOtherStreet != NULL){
     
     myStrings = a.PersonOtherStreet.split('\n');
            a.Other_Building_Floor_Department__c = '';
            a.Other_Street_PO_Box__c = '';
            a.Other_Suite__c = '';
           
            k=mystrings.size();
            system.debug(k);
            system.debug(a.PersonOtherStreet);
        
            if(k > 2){
                for(i = 2; i < k; i++){
                    if(myStrings[i] == '')
                        break;
                    else
                        address3 += myStrings[i].trim()+' '; 
                    }
              a.Other_Street_PO_Box__c = address3;
              a.Other_Suite__c = myStrings[0];
              a.Other_Building_Floor_Department__c = myStrings[1];
             
         address3 = '';
            }
            else if(k == 2) 
            {
                
                a.Other_Building_Floor_Department__c = myStrings[1];
                a.Other_Suite__c = myStrings[0];
                
            }
            
            else if(k == 1) a.Other_Suite__c = myStrings[0];
 
            
          
       }
     }
   }
//Code commented per WO 1504 to remove SapShareUpdate__c field 
/*
if(trigger.isUpdate)
{
    Account[] rows2processNew = new Account[]{};
    Account[] rows2processOld = new Account[]{};
    for(integer p = 0; p < Trigger.new.size(); p++) {
        Account newRow = Trigger.new[p];
        if ( !(newRow.SapShareUpdate__c == true) ) continue;
        newRow.SapShareUpdate__c = false;
        rows2processNew.add(Trigger.new[p]);
        rows2processOld.add(Trigger.old[p]);
    }
    if ( rows2processNew .size() > 0 )
        AccountShareHandler.beforeUpdate(rows2processOld, rows2processNew);
}
*/
}