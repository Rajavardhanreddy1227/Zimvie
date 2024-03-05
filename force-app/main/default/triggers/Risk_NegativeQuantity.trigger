trigger Risk_NegativeQuantity on OpportunityLineItem (before insert) 
{
    if(Trigger.isInsert)
    {
        set<id> oppid = new set<id>();
        for (OpportunityLineItem  oli : trigger.new)
        { 
            oppid.add(oli.opportunityid);
        }
        Id RevenueRisk= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Revenue Risk').getRecordTypeId();
        list<opportunity> opplist = [select id, recordtype.name,recordtypeid from opportunity where id in : oppid ];
        for (OpportunityLineItem  oli : trigger.new)
        {    
            for (opportunity opp: opplist)
            {
                if (oli.opportunityid == opp.id)
                {
                    if(opp.recordtype.name == 'Revenue Risk')
                    {
                        if(oli.Quantity > 0)
                        {
                           oli.Quantity = oli.Quantity * -1;
                        }
                    }
                }
            }
        }
    }
}