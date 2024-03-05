global class B2B_BuyerGroupMemberBatch implements Database.batchable<BuyerGroupMember>
{ 
    List<BuyerGroupMember> lstbgms;
    public B2B_BuyerGroupMemberBatch(List<BuyerGroupMember> lstbgms){
        this.lstbgms = lstbgms; 
    }
    global Iterable<BuyerGroupMember> start(Database.batchableContext info)
    { 
        return new b2b_BgmRecords(lstbgms); 
    }     
    global void execute(Database.batchableContext info, List<BuyerGroupMember> scope)
    { 
        Set<Id> setaccId = new Set<Id>();
        for(BuyerGroupMember objBgm : scope){
            setaccId.add(objBgm.BuyerId);
        }
        if(setaccId != null && setaccId.size() > 0){
            database.delete ([Select Id from BuyerGroupMember where BuyerId IN:setaccId],false);
        }
        database.insert(scope,false); 
    }     
    global void finish(Database.batchableContext info)
    {     
    } 
}