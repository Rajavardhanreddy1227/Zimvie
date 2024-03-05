public class Discussion_Board
{
/*
Discussion_Board__c[] MyDiscussion;
    //Method to get the Discussion Board from  Discussion_Board__c with respect to user LOB
    
     public List<Discussion_Board__c> getdiscussionDetail() 
     {
     //Checking the provided ID parameter in current page 
     User LOBLIST = [select id,Name,ProfileId from User where Id = :UserInfo.getUserId() Limit 1];

        Profile[] ProfileName = [Select Id, Name from Profile where id =:LOBLIST.ProfileId  ];

        if (ProfileName.size() > 0)
            {
            if (ProfileName [0].Name ==  null)
                {
                ProfileName[0].Name = 'Standard User';
                }
            }
        else 
            {
            ProfileName[0].Name = 'Standard User';
            }
         System.debug('Profile.Name##########' +   ProfileName[0].Name);
        
        Discussion_Board__c[] MultiSelectBull;
          
    string tregion = 'Americas';
    //string tregion;

    if (ProfileName[0].Name.contains('EU'))
    {
      tregion  = 'EMEA';
    }     
    else if (ProfileName[0].Name.contains('ANZ') || ProfileName[0].Name.contains('JPN'))
    {
      tregion  = 'APAC';
    }
    else
    {
      tregion  = 'Americas';
    } 

   MyDiscussion= [select id,Discussion_Intro__c,Full_Content__c ,Name from Discussion_Board__c where Active__c= true and  region__c INCLUDES (:tregion) Order By LastModifiedDate DESC Limit 1];
      
      
        if (MyDiscussion.size() <= 0)
            {
            Discussion_Board__c test = new Discussion_Board__c();
            test.Discussion_Intro__c ='Not Available';
            test.Full_Content__c ='Not Available';
            MyDiscussion.add(test);
            } 
       
   return MyDiscussion;
        //retun the value to the calling page 
   }
   */
}