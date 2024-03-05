trigger UpdateUserProfile on User (before update, before insert) {

    List<User> users = Trigger.new;

    for(User u :users)
    {
        if(u.profileId == '00eC0000001STnY')
        {
            u.profileId = '00eC0000001SryM';  
        }
        
        else if(u.profileId == '00eC0000001SlEl')
        {
            u.profileId = '00eC0000001SlFF';
        }
    }    
 
}