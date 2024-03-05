global class AccountValidation
{
    Webservice String CountryCode;
    Webservice String CustomerNumber;

    global class AccountOutput{
        Webservice String Flag;
    }

    Webservice static String AccountInfo(String CountryCode, String CustomerNumber){

        String a=String.escapeSingleQuotes(CountryCode);
        String b=String.escapeSingleQuotes(CustomerNumber);
        String Ss1;
        String Ss2;
        String Country;

            if((a=='United States'||a=='Canada')&& b<>''){
                
                if (a=='United States') Country='US';
                else if (a=='Canada') Country='CA';
                
                Ss1='DNB3'+Country+b+'-%';
                list<Account> l1=[select name from Account where Customer_Number__c LIKE :Ss1 AND RecordTypeId = '012C0000000UlfO' limit 1];
                
                Ss2=b+'-%';
                list<Account> l2=[select name from Account where Customer_Number__c LIKE :Ss2 AND RecordTypeId = '012C0000000UlfO' limit 1];
                
                if(l1.size()==0 && l2.size()==0){
                    AccountOutput Acc=new AccountOutput ();
                    Acc.Flag='-1';
                    system.debug('When customernumber is not blank and Country code as CA or US the flag ='+Acc.Flag);
                    return Acc.Flag;
                }
                
                else {
                    AccountOutput Acc=new AccountOutput ();
                    Acc.Flag='1';
                    system.debug('When Account present then flag='+Acc.Flag);
                    return Acc.Flag;
                }
            }

         else if(a=='' && b=='')  {
                AccountOutput Acc=new AccountOutput ();
                Acc.Flag='0';
                system.debug('When customernumber and Country code is blank the flag='+Acc.Flag);
                return Acc.Flag;
            }
            

          else {
               AccountOutput Acc=new AccountOutput ();
                Acc.Flag='-1';
                system.debug('When customernumber and Country code are  not blank the flag='+Acc.Flag);
                return Acc.Flag;
            }
    }
}