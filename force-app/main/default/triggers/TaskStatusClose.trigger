//******************************************************************************************//
// Trigger name: TaskStatusClose                                                            **
// Author: Arun Kumar Singh                                                                 **
// Created On: 09/29/2011                                                                   **
// Modified On 09/30/2011                                                                   **
// Purpose :This Trigger Changes the status of all the tasks to closed, that are            **
//            Created by the profile of AM-US-Executive Outreach, created on a person       **
//          Account and where the required field is always flagged.                         **
//********************************************************************************************

trigger TaskStatusClose on Task (after insert) 
{
    Integer i;
    list<id> WhatId = new list<id>();
    //**Getting What Id value from Trigger.New**//
    for(task x : trigger.new)
    {
        WhatId.add(x.whatid);
    }
    
    //** Checking for User Profile **//
    Profile p=[select Id,name from Profile where Name='AM-US-Executive Outreach'];
    if(UserInfo.getProfileId()==p.Id)
    {
        //** Selecting all the tasks that are present in Trigger.New **//
        list<task> NewTasks = new list<task>([select id,whatid from task where id IN : trigger.new]);
        
        //** Selecting all the Accounts that have there Id's in Trigger.New as WhatId's **//
        list<Account> TaskAccounts = new list<Account>([select id,recordtypeid,Top_350__c from Account where id IN:WhatId]);
        
        //** Selecting all thos tasks that are present on the above accounts **//
        list<task> NewTask1 = new list<task>([select id,status from task where whatid IN: TaskAccounts ]);
        for(Account TaskAcc:TaskAccounts)
        {
            //** Checking for Account record Type **//
            if(TaskAcc.recordtypeid=='012800000002C4g')
            {
                //** Checking for the Required Field Condition **//
                if(TaskAcc.Top_350__c == true)
                {
                    for(task task1:NewTasks)
                    {
                        for(task task2:NewTask1)
                        {
                            //** Checking if the task is the correct task **//
                            if(task1.id==task2.id)
                            {
                                task2.status='Completed';
                            }
                        }
                    }
                }
            } 
        }update NewTask1;
    } 
}