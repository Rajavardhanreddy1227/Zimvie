//*******************************************************************************************************************************//
// Trigger to update DN GLBL CONTACT OWNER to match the ACCOUNT OWNER 
// Developer : Hardeep Brar
// Version   : 1.0
// Object    : Case
// Class     : DNGlobalContactOwnerData 
//*******************************************************************************************************************************//


trigger DNGlobalContactOwnerUpdate on Contact (before insert, before Update) {

 DNGlobalContactOwnerData.ContactCopier(Trigger.new);

}