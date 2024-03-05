global class b2b_CustomIterable implements Iterator<BuyerGroupMember>
{ 

    List<BuyerGroupMember> lstbgms;
    Integer i {get; set;} 

    public b2b_CustomIterable(List<BuyerGroupMember> lstbgms)
    { 
        this.lstbgms = lstbgms; 
        i = 0; 
    }   

    global boolean hasNext()
    { 
        if(i >= lstbgms.size()) 
        {
            return false; 
        } else 
        {
            return true; 
        }
    }    

    global BuyerGroupMember next()
    {  
        i++; 
        return lstbgms[i-1]; 
    } 
}