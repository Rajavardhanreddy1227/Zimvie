//*******************************************************************************************************************************//
// Dental trigger to copy Account Phone field (the phone number) and copies (only digits) it into the Account Custom field called DN-Datatrim Phone Match  
// Developer : Hardeep Brar
// Version   : 1.0
// Object    : Case
// Class     : DNGlobalContactOwnerData 
//*******************************************************************************************************************************//

trigger DNDatatrimPhoneUpdate on Account (before insert, before update) {

DNDatatrimPhoneData.AccountPhoneCopier(Trigger.new);

}