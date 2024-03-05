trigger InstrumentRequest on Instrument_Request__c (before insert, before update,after insert, after update) {
    /* This trigger does following things...
    1- Persist SNAP Kit Number
    2- Calculates a Status field that goes on Opportunity Record
    3- Calculates an order for record based on Opportunity Id

    */
    switch on Trigger.operationType{
        when AFTER_INSERT {
            InstRqstHandler.onAfterInsertUpdate(Trigger.New, Trigger.oldMap);
        }
        when AFTER_UPDATE{
            InstRqstHandler.onAfterInsertUpdate(Trigger.New, Trigger.oldMap
            );
        }
        when BEFORE_INSERT{
            InstRqstHandler.onBeforeInsertUpdate(Trigger.New);
        }
        when BEFORE_UPDATE{
            InstRqstHandler.onBeforeInsertUpdate(Trigger.New);
        }
    }
    
}