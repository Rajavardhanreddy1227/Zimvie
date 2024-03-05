//***************************//
        // Developer  : Hardeep Brar
        // Version    : 1.0
        // Object     : Account
        // Class      : DentalAccountTriggerHandler
        // Trigger    : UpdateDentalAccountOwner
        // Description: When any DN-ACCT-RECORD-TYPE Record will be created in Salesforce, then this trigger will update the Account 
        //              Owner for that record, to be same as provided Salesperson ID, if valid user with alias = Salesperson ID exists
        //              in the system.
        //***************************//


Trigger UpdateDentalAccountOwner on Account (Before Insert, Before Update) 
    {
        IF(Trigger.IsBefore)
        {
            IF(Trigger.IsInsert || Trigger.IsUpdate)        
            {
                DentalAccountTriggerHandler.UpdateAccOwner(Trigger.New);
                DentalAccountTriggerHandler.UpdateAccOwner2(Trigger.New);
            }
        }
    }