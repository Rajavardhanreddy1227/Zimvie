//***************************//
        // Developer  : Hardeep Brar
        // Object     : Account
        // Class      : AccountValidation
        //***************************//
        
        

        
@isTest (seeAllData=false)
private class AccountValidationTest{

            private static testmethod void basic()
            {
               Test.startTest(); 
               
                AccountValidation.AccountInfo('United States','102481');
                AccountValidation.AccountInfo('Canada','928701');
                System.debug('Customer Number: DE ----- Country Code: 103524');
                AccountValidation.AccountInfo('DE','103524');
                System.debug('Customer Number: US ----- Country Code: 425537 ');
                AccountValidation.AccountInfo('US','425537');
                System.debug('Customer Number:  ----- Country Code: ');
                AccountValidation.AccountInfo('','');
                System.debug('Customer Number: ----- Country Code:  DNB3US101783');
                AccountValidation.AccountInfo('','DNB3US101783');
                System.debug('Customer Number: ------ Country Code: DE  ');
                AccountValidation.AccountInfo('DE','');
                                
               Test.stoptest();
        
            }
}