@isTest
public class TestUpdateSCAccOwner {
    
    @isTest
    public static void updateSCAccOwnerTest(){
        Account acc = new Account();
        acc.RecordTypeId = '012C0000000QZHjIAO';
        Database.SaveResult res = Database.insert(acc,false);
    }
}