trigger SalesPlanOwnerUpdate on Opportunity (before insert, before update) {
    for(Opportunity o:Trigger.new){
        if(o.Sales_Plan_Owner__c != null && o.Distributor_RecordType__c == '012800000002ByT')
            o.ownerId = o.Sales_Plan_Owner__c;
    }
    
}