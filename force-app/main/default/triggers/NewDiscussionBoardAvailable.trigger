trigger NewDiscussionBoardAvailable on Discussion_Board__c (after insert,after update) {
/*
if(ContactOwnerUpdate.hasAlreadyLaunchedUpdateTrigger()==false)
{
ContactOwnerUpdate.setAlreadyLaunchedUpdateTrigger();
List<User> UpdateUsers = new List<User>();
UpdateUsers=[Select Bulletin_Board__c from User where Bulletin_Board__c=true AND IsActive=true ];
System.debug('************Inside New DiscussionBoard Available****');
For(User UpdateUser : UpdateUsers)
{
UpdateUser.Bulletin_Board__c=false;
System.debug('************Inside New DiscussionBoard Available2****');
}
System.debug('************Inside New DiscussionBoard Available2****');
Update UpdateUsers;
System.debug('************Inside New DiscussionBoard Available3****');

}
*/
}