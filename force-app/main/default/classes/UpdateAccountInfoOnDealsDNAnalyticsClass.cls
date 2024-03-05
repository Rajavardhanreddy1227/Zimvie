//***************************//
        // Developer  : Hardeep Brar
        // Trigger    : UpdateAccountInfoOnDealsDNAnalytics
        //***************************//

        public class UpdateAccountInfoOnDealsDNAnalyticsClass {

            public static void AccountPhoneCopier(List<Account> accList ){
          
          for (Account acc : accList)
                            
                    if(acc.RecordTypeId<>'012C0000000UlfO' || acc.RecordTypeId<>'012C0000000UlfOIAS' ) 
                                {                                    
                                   System.debug('YES');
                                  
                                }
          

            }
        }