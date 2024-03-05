global  with sharing class POCreateShareSchedulableJob implements Schedulable {
   
    global void execute(SchedulableContext sc) {
        PODailyCreateShareJob b = new PODailyCreateShareJob(); 
        database.executebatch(b);
     }
}