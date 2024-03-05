trigger updateUserforBulletinBoard on Discussion_Board__c (Before insert,Before update) {
    

list<user> Objdiscussionone = new list<user>();
String RegionDetails;
Boolean EnableforAmericas = false;
Boolean EnableforEMEA = false;
Boolean EnableforAPAC = false;
System.debug('************Inside updateUserforBulletinBoard trigger****');


    for(Discussion_Board__c ObjNew: Trigger.new)
        {
        
               RegionDetails = ObjNew.region__c;
                if(BulletinTriggerCheck.firstRun && ObjNew.active__C ==true  )
                  {
                  ObjNew.active__C =true;
                  }
               if( BulletinTriggerCheck.firstRun && RegionDetails <> null  && RegionDetails  <>'' && ObjNew.active__C ==true )
                 {
                 
                    BulletinTriggerCheck.firstRun = false;
                  
                    UpdatebulletinBoardtoInactive ObjVal = new UpdatebulletinBoardtoInactive ();
                    ObjVal.manualbulletinBoardtoInactive (true,ObjNew.ID,RegionDetails );
                  }
                  ObjNew.Bulletin_Board_Date__c = System.Now();
                 
           }

           
}