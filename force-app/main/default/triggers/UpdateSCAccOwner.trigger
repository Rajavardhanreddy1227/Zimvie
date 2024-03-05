trigger UpdateSCAccOwner on Account (before insert, before update) {
    
    for(Account a : Trigger.New){
        if(a.recordTypeId == '012C0000000QZHjIAO'){
            a.OwnerId = '0053b00000CUxjwAAD';
        
        }
    }

}