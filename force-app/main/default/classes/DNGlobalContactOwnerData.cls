//***************************//
        // Developer  : Hardeep Brar
        // Version    : 1.0
        // Object     : Case
        // Trigger    : DNGlobalContactOwnerUpdate
        //***************************//

        public class DNGlobalContactOwnerData {

            public static void ContactCopier (List<Contact> conList){
                  
                 //List<Contact> contacts = Trigger.new;
                
                /* Fetching details of the Account that are related with the Contacts in conList */
                Set<Id> accountIds = new Set<Id>();
                for (Contact cont : conList) {
                    accountIds.add(cont.AccountId);
                }

                Map<Id, Account> mapAccount = new Map<Id, Account>([SELECT Id, OwnerId ,Owner.IsActive FROM Account WHERE Id IN :accountIds]);
                for(Contact cont : conList)
                {
                
                    if(mapAccount.size()>0){
                        if(cont.AccountId!=null){
                            if((mapAccount.get(cont.AccountId).Owner.IsActive == TRUE) &&(cont.RecordTypeId=='012C0000000UlfT'))
                            {
                               cont.OwnerId=mapAccount.get(cont.AccountId).OwnerId;     
                            }
                         }
                    }
                
                }


            }
        }