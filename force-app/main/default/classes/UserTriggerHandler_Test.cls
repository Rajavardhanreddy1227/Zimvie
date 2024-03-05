@isTest
public class UserTriggerHandler_Test {
    
     @testSetup static void setup() {
        
        Trigger_Settings__c cs = new Trigger_Settings__c();
        cs.Name = 'AddUsersToPSQueues Trigger';
        cs.Active__c = true;
        insert cs;
        
    }
    
    static testMethod void validateUserAddedToQueue() {
        
        list<User> insertusers = new list<User>();
        UserRole uRole;
        Group Psgrp;
        QueuesObject q1;
        
        test.startTest();
        
        Psgrp = new Group(Name= 'PS-test',Type ='Queue');
        insert Psgrp;
        
        q1 = new QueueSObject(QueueID = Psgrp.id, SobjectType = 'Case');
        insert q1;
        
        uRole=new UserRole(Name='Personalized Solutions Manager'); 
        insert uRole;
        
        
        Profile pro = [select Id, Name from Profile where Name = 'Custom - Personalized Solutions Call Center Agent'];
        
        
        for(Integer i=0;i<50;i++)
        {
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = pro.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName=uniqueName+'@test'+ orgId+'.com',UserRoleId = uRole.Id);
            insertusers.add(u);
        }
        
        
        insert insertusers; 
        
        test.stopTest();
        
    }
    
    static testMethod void validateUserAddedToQueue_Exception() {
        
        test.startTest();
        
        try{
            list<User> insertusers = new list<User>();
            UserRole uRole;
            Group Psgrp;
            QueuesObject q1;
            
            Psgrp = new Group(Name= 'PS-test',Type ='Queue');
            insert Psgrp;
            
            q1 = new QueueSObject(QueueID = Psgrp.id, SobjectType = 'Case');
            insert q1;
            
            uRole=new UserRole(Name='Personalized Solutions Manager'); 
            insert uRole;
            
            
            Profile pro = [select Id, Name from Profile where Name = 'Custom - Personalized Solutions Call Center Agent'];
            
            
            for(Integer i=0;i<50;i++)
            {
                String orgId = UserInfo.getOrganizationId();
                String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
                Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
                String uniqueName = orgId + dateString + randomInt;
                
                User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                  EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = pro.Id, 
                                  TimeZoneSidKey='America/Los_Angeles', UserName=uniqueName+'@test'+ orgId+'.com',UserRoleId = uRole.Id);
                insertusers.add(u);
            }
            
            
            insert insertusers; 
            
        }
        
        Catch (Exception e){
                        
        }
        
        test.stopTest();
        
    }
    
}