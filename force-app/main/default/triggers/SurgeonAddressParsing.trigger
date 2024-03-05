trigger SurgeonAddressParsing on Account (before insert, before update) {
 //******************************************************************************************//
 // Trigger name: SurgeonAddressParsing
 // Author: Saikishore Aengareddy
 // Date of last modification: 11/02/2010
 // Purpose of this trigger: Parses the Mailing street and Other street into 3 address lines
 //******************************************************************************************//

    integer i,k;
    string address3 = '';
    
    for(Account a: trigger.new) {
      if(a.RecordTypeId == '012800000002C4gAAE' || a.RecordTypeId == '012800000003YRmAAM' || a.RecordTypeId == '012800000003YRcAAM' || a.RecordTypeId == '012800000003YRrAAM' || a.RecordTypeId == '012800000003YRhAAM' || a.RecordTypeId == '012800000003YRnAAM')
       {
        String[] myStrings = new String[10];
        if(a.PersonMailingStreet != NULL){
            myStrings = a.PersonMailingStreet.split('\n');
            k=mystrings.size();
        
            if(k > 0 && !(mystrings[0] == ''))
                a.Office_Suite__c = myStrings[0];
 
            if(k > 1 && !(mystrings[1] == ''))
                a.Office_Building_Floor_Department__c = myStrings[1];
       
            if(k > 2){
                for(i = 2; i < k; i++){
                    if(myStrings[i] == '')
                        break;
                    else
                        address3 += myStrings[i].trim()+' '; 
                    }
              a.Office_Street_PO_Box__c = address3;
             }
         address3 = '';
       }
     
     if(a.PersonOtherStreet != NULL){
            myStrings = a.PersonOtherStreet.split('\n');
            k=mystrings.size();
        
            if(k > 0 && !(mystrings[0] == ''))
                a.Other_Suite__c = myStrings[0];
 
            if(k > 1 && !(mystrings[1] == ''))
                a.Other_Building_Floor_Department__c = myStrings[1];
         
            if(k > 2){
                for(i = 2; i < k; i++){
                    if(myStrings[i] == '')
                        break;
                    else
                        address3 += myStrings[i].trim()+' '; 
                }
              a.Other_Street_PO_Box__c = address3;
           }
         address3 = '';
       }
     }
   }
 }