//***************************//
        // Developer  : Hardeep Brar
        // Version    : 1.0
        // Object     : Account
        // Trigger    : DNDatatrimPhoneUpdate
        //***************************//

        public class DNDatatrimPhoneData {

            public static void AccountPhoneCopier(List<Account> accList ){
                 
                /* Fetching details of the Account that are related with the Contacts in conList */
                
                for (Account acc : accList)
                            
                    if( (acc.RecordTypeId=='012C0000000UlfO' || acc.RecordTypeId=='012C0000000UlfOIAS' ) && (acc.Phone!= null))
                                {                                    
                                   String phoneDigits = String.valueOf (acc.Phone);
                                    // remove all non numeric
                                   String phoneTrim = phoneDigits.replaceAll('[^0-9]','');
                                    acc.DN_Datatrim_Phone_Match__c = phoneTrim;     
                                }
                                
            }
        }