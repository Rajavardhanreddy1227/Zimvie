@isTest
public class Ortho_FeedCommentHandlerTest {
    
    @testSetup
    public static void createTestData(){
        Account a = TestUtilsLocal.createAccount('Test Account',true);
        FeedItem fi = new FeedItem(Body='Test feed',ParentId=a.Id);
        insert fi;
        FeedComment c = new FeedComment(CommentBody='TestComment', FeedItemId=fi.id);
        insert c;
    }
	
    @isTest
    static void testDisableCommentsInCommunicationGroups(){
        List<FeedComment> fc = [Select CommentBody,ParentId from FeedComment];
        Test.startTest();
        Ortho_FeedCommentHandler.onBeforeInsert(fc);
        Test.stopTest();
    }
}