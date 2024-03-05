/**
* @author Appirio Inc.
* @date March, 2020
*
* @description Running for Ortho_CollaborationGroupMemberHandler
*       For more guidelines and details see
*    https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Domain_Layer
*/
@isTest
public class Ortho_CollabGroupMemberHandlerTest {
    @testSetup
    public static void TestSetup1(){
        
       //Create User
        User usr = TestUtilsLocal.createTestUser('Test@@2', true);
        
        //Create Collaboration Group
        CollaborationGroup cg = new CollaborationGroup(Name = 'My Group@@2',
                                                      CollaborationType = 'Private');
        Insert cg;
        
        //cg = [SELECT Id, Name FROM CollaborationGroup WHERE Name = 'Leadership Communications'];
        
        //Create Collaboration Group Member
       CollaborationGroupMember cgm = new CollaborationGroupMember(NotificationFrequency = 'd',
                                                                    MemberId = usr.Id,
                                                                    CollaborationGroupId = cg.id); 
        Insert cgm;
    }
    
    //Update CollaborationGroupMember
    @isTest
    public static void onUpdate(){ 
        
        Test.startTest();
            List<CollaborationGroupMember> cgm = [SELECT NotificationFrequency, Id FROM CollaborationGroupMember 
                                                  WHERE CollaborationGroup.Name = 'My Group@@2'];
            cgm[0].NotificationFrequency = 'p';
            UPDATE cgm[0];
            Test.stopTest();
    }
}