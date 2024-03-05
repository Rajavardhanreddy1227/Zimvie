trigger UpdateOppAccessOnTerritory on Territory2 (before insert) {
    
    if (Trigger.isInsert) 
    {
        Territory2Type tType = [SELECT id, DeveloperName from Territory2Type where DeveloperName =:'US_Ortho'];
        Territory2Model tModel = [SELECT id, DeveloperName from Territory2Model where DeveloperName =:'Zimmer_Biomet'];
        
        for(Territory2 terr : Trigger.new)
        {
            system.debug('--tType.Id--'+tType.Id);
            system.debug('--tModel.Id--'+tModel.Id);
            
            system.debug('--terr.Territory2TypeId--'+terr.Territory2TypeId);
            system.debug('--terr.Territory2ModelId--'+terr.Territory2ModelId);
            
            if(terr.Territory2ModelId == tModel.Id && terr.Territory2TypeId == tType.Id)
            {
             	  terr.OpportunityAccessLevel = 'Read';
            }
        }
    }
}