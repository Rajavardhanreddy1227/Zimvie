public class UpdatebulletinBoardtoInactive {

 public void manualbulletinBoardtoInactive (boolean status,id bullId,string region)
 {
   /*
   String[] MultiRegion,FilterMultiRegion;
   integer Count = 0;
     String Link = '';
 
   if (status && region <> null && region <> '')
   { 
    list <Discussion_Board__c> objbullBoard= new List<Discussion_Board__c>();
     system.debug('region' + region);
 
     MultiRegion = region.Split(';') ;
     system.debug('MultiRegion ' + MultiRegion );
     for(Discussion_Board__c bullet:[select id ,region__c,active__C from Discussion_Board__c where active__C =true and id != :bullId and  (region__c = '' or region__c INCLUDES (:region)or  region__c in :MultiRegion )])
     {
          system.debug('bullet--' + bullet);
       if (bullet.region__c <> '' && bullet.region__c <> null)
       {
        String interimregion =bullet.region__c;
        FilterMultiRegion =interimregion.Split(';') ;
        String[] tempFilterMultiRegion  = FilterMultiRegion ;
        if( FilterMultiRegion.size() <=MultiRegion.size())
           {
            bullet.active__C = false;
           }
           else
           {
           integer[] variablecount;
            if(FilterMultiRegion.size() > MultiRegion.size())
            {
            variablecount= new Integer[FilterMultiRegion.size()];
            }
            else
            {
              variablecount= new Integer[MultiRegion.size()];
            }
            
             for(string removeregion:MultiRegion )
             { 
                 Count = 0;
                 for(string tmpregion:tempFilterMultiRegion  )
                {
                  if(removeregion== tmpregion)
                  {
                  System.debug('removeregion'+ removeregion);
                    variablecount.add(Count );
                    
                  }
                  Count = Count + 1;
                }
                System.debug('Count=' + Count  );
                System.debug('variablecount=' + variablecount);
                
                 for(integer icount =0 ;icount<= Count ;icount ++)
                 {  
                     if(variablecount[icount] <> null) {
                     System.debug('tempFilterMultiRegion--' + tempFilterMultiRegion[variablecount[icount]]);
                     tempFilterMultiRegion.remove(variablecount[icount] );  
                     }
                 }
             }
             
             for(string removeregion:tempFilterMultiRegion){
                  Link = Link  + removeregion + ';'; 
                  
                  
              }
              bullet.region__c = Link ;
            
           }
       } 
       else
       {
          bullet.active__C = false;
       }    
       objbullBoard.add(bullet);
    }
      system.debug('objbullBoard' + objbullBoard);
      update objbullBoard;
   }
  */
 }
 
 
}