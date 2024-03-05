@isTest
public class Ortho_CommunicationsControllerTest {

    @isTest
    public static void isGroupAdminTest(){
        CollaborationGroup myCg = new CollaborationGroup(name = 'test123', CollaborationType='Private');
        insert myCg;
        User usr = TestUtilsLocal.createTestUser('OrthoTest1', true);
        
        Test.startTest();
        
        CollaborationGroupMember cgm1 = new CollaborationGroupMember(NotificationFrequency = 'd',
                                                                    MemberId = usr.Id,
                                                                    CollaborationRole = 'Admin',
                                                                    CollaborationGroupId = myCg.id);
        INSERT cgm1; 

        Boolean isAdmin = Ortho_CommunicationsController.isGroupAdmin(myCg.Id);
        Test.stopTest();
        
        system.assertEquals(true, isAdmin);

    }
    @IsTest(SeeAllData=true)
    public static void getAnnouncementsTest(){
        
        CollaborationGroup myCg = new CollaborationGroup(name = 'test452', CollaborationType='Private');
        insert myCg;
        CollaborationGroupMember cgm = new CollaborationGroupMember();
        List<CollaborationGroupMember> cgmList = new List<CollaborationGroupMember>();
        Set<Id> cgIds = new Set<Id>();
        
        Test.startTest();
        List<CollaborationGroup> cgList = new List<CollaborationGroup>{myCg};
        
        for(CollaborationGroup cg : cgList){
            cgIds.add(cg.Id);
        }
        
        
        for(Id cg : cgIds){
            cgmList.add(new CollaborationGroupMember(NotificationFrequency = 'd',
                                                     MemberId = UserInfo.getUserId(),
                                                     CollaborationRole = 'Admin',
                                                     CollaborationGroupId = cg));
        }
        try{
            INSERT cgmList; 
        }
        catch(System.DmlException ex){
            if(!ex.getMessage().contains('DUPLICATE_VALUE')){
                throw ex;
            }
        }

        ConnectApi.AnnouncementInput announcement = new ConnectApi.AnnouncementInput();
        announcement.expirationDate= datetime.now()+10; // Announcement Expiration Time, usually it will be expire on end of the day.
        announcement.sendEmails=false;
        announcement.ParentID=myCg.Id;
        
        ConnectApi.MessageBodyInput bodyInput = new ConnectApi.MessageBodyInput();
        bodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = 'Tets';
        bodyInput.messageSegments.add(textSegment);
        announcement.Body = bodyInput;
        
        ConnectApi.Announcements.postAnnouncement(null, announcement);
        
        List<ConnectApi.Announcement> announcementList = new List<ConnectApi.Announcement>();
        announcementList = Ortho_CommunicationsController.getAnnouncements();
        Test.stopTest();
        //System.assertEquals(1, announcementList.size());
    }
}