global class b2b_BgmRecords implements iterable<BuyerGroupMember>
{
    List<BuyerGroupMember> lstbgms;
    public b2b_BgmRecords(List<BuyerGroupMember> lstbgms)
    {
        this.lstbgms = lstbgms; 
    }
    global Iterator<BuyerGroupMember> Iterator()
    {
        return new b2b_CustomIterable(lstbgms);
    }
}