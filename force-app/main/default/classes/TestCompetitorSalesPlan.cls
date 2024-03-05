public class TestCompetitorSalesPlan{

    public static testmethod void tm_savesfdc(){

        try{
            Opportunity opp = new Opportunity();
            opp.Name = 'a';
            opp.CloseDate = Date.today();
            opp.StageName = 'Prospecting';
            opp.Competitor__c = 'A';
            insert opp;
            opp.Competitor__c = '';
            update opp;
            opp.Competitor__c = 'B';
            update opp;

            Competitor__c[] QueryComp;
            QueryComp = [select id from Competitor__c where Sales_Plan__c =: opp.id];

            if (QueryComp.size() > 0){
                delete QueryComp;
            }
        }
        catch (Exception e){
            system.debug(e);
        }
    }
}