trigger CompetitorSalesPlanLink on Opportunity(after insert,after update){

    if(Trigger.IsInsert){
        Competitor__c[] CompetitorNew = new Competitor__c[]{};

        for (Opportunity opp : Trigger.new){
            if(opp.Competitor__c <> '' && opp.Competitor__c <> null){
                Competitor__c NewRecordCompetitor = new Competitor__c();
                NewRecordCompetitor.Competitor__c = opp.Competitor__c;
                NewRecordCompetitor.Primary_Competitor__c = True;
                NewRecordCompetitor.Sales_Plan__c = opp.id;
                CompetitorNew.add(NewRecordCompetitor);
            }
        }

        if(CompetitorNew.size() > 0){
            insert CompetitorNew;
        }
    }

    if(Trigger.IsUpdate){
        String[] IdOppDelete = new String[]{};
        Competitor__c[] CompetitorNew = new Competitor__c[]{};
        Integer i;

        for (i=0;i<Trigger.new.size();i++){
            if(Trigger.new[i].Competitor__c == '' || Trigger.new[i].Competitor__c == null){
                IdOppDelete.add(Trigger.new[i].id);
            }
            else if(Trigger.new[i].Competitor__c <> Trigger.old[i].Competitor__c){
                IdOppDelete.add(Trigger.new[i].id);
                Competitor__c NewRecordCompetitor = new Competitor__c();
                NewRecordCompetitor.Competitor__c = Trigger.new[i].Competitor__c;
                NewRecordCompetitor.Primary_Competitor__c = True;
                NewRecordCompetitor.Sales_Plan__c = Trigger.new[i].id;
                CompetitorNew.add(NewRecordCompetitor);
            }
        }

        if(IdOppDelete.size() > 0){
            Competitor__c[] QueryDelete;
            Competitor__c[] CompetitorDelete = new Competitor__c[]{};

            QueryDelete = [select id,Overwrite_Delete__c from Competitor__c where Sales_Plan__c IN :IdOppDelete and Primary_Competitor__c = True];

            if(QueryDelete.size() > 0){
                for (Competitor__c comp : QueryDelete){
                    comp.Overwrite_Delete__c = True;
                    CompetitorDelete.add(comp);
                }

                update CompetitorDelete;
                delete CompetitorDelete;
            }
       }

       if(CompetitorNew.size() > 0){
           insert CompetitorNew;
       }
    }
}