@isTest
public class UpdateOppAccessOnTerritory_Test {
    
    @testSetup static void setup() {        
        
    }
    
    public static testMethod void TestUserCreationWithContact()
    {
        test.startTest();
        
        Territory2Type tType = [SELECT id, DeveloperName from Territory2Type where DeveloperName = 'US_Ortho'];
        
        Territory2Model tModel = new Territory2Model();
        tModel.DeveloperName = 'Test_Model';
        tModel.Name = 'Test Model';
        insert tModel;
        
        List<Territory2> terrList = new List<Territory2>();
        for(Integer i=1; i<=50; i++){
            Territory2 terr = new Territory2();
            terr.Name = 'Test Terr '+i;
            terr.DeveloperName = 'Test_Terr_'+i;
            terr.AccountAccessLevel = 'Read';
            terr.CaseAccessLevel = 'Read';
            terr.Territory2TypeId = tType.Id;
            terr.Territory2ModelId = tModel.Id;
            terrList.add(terr);
        }
        
        insert terrList;
        
        test.stopTest();                       
    }     
    
}