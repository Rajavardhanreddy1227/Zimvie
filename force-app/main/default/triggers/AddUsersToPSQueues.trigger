trigger AddUsersToPSQueues on User (after insert) {
    
    Boolean isActive = Trigger_Settings__c.getInstance('AddUsersToPSQueues Trigger').Active__c; // check if trigger is Active
    
    Public list<Group> getgroups = new list<Group>(); // list to hold the PS Queues
    Public list<GroupMember> Insertgroupmembers = new list<GroupMember>(); // list to holds the new GroupMember    
    public map<Id, String> usrRoleMap = new map<Id, String>(); //map to hold the PS User roles
    
    public set<String>queuesNotIncluded = new set<String>(); // Queues Not to be included
    queuesNotIncluded.add('PS- Clinical Graphics'); 
    queuesNotIncluded.add('PS- Manager');
    
    if(isActive){
        
        //TriggerFactory.createHandler(User.sObjectType); 
        
        if(Trigger.isAfter){
            
            //get the Queues stating with name Like 'PS-'
            getgroups = [select Id,Name from Group where Type = 'Queue' AND Name LIKE '%PS-%' AND Name NOT IN:queuesNotIncluded];
            system.debug('----getgroups----: '+getgroups.size());
            
            //get the Userrole with name Like 'Personalized Solutions'
            for(UserRole r : [select Id, Name from UserRole where Name LIKE '%Personalized Solutions%'])
            {
                usrRoleMap.put(r.Id, r.Name);
            }
            
            if(trigger.isInsert){
                
                for (User usr : Trigger.new)
                {
                    if(usr.IsActive == true)
                    {
                        string uRole = '';
                        //check if map contains  the user role, if yes get the role id
                        if(usrRoleMap.containsKey(usr.UserRoleId))
                        {
                            uRole = usrRoleMap.get(usr.UserRoleId);
                            
                            //check if role name contains 'Personalized Solutions'
                            if(uRole.contains('Personalized Solutions'))
                            {
                                // iterate over PS Groups to add new PS users as GroupMember
                                for(Group grp : getgroups)
                                {
                                    GroupMember member = new GroupMember();
                                    member.UserOrGroupId = usr.Id;
                                    member.GroupId = grp.Id;
                                    Insertgroupmembers.add(member); 
                                }
                            }
                        }
                    }
                }
            }  
        }//is After
        
        
        if(!Insertgroupmembers.isEmpty())
        {
            system.debug('Insertgroupmembers  ==  : '+Insertgroupmembers.size());
            //insert the new members records
            insert Insertgroupmembers;    
        }
    }
}