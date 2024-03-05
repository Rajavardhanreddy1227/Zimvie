public with sharing class Ortho_OpportunityComponentController{
public static boolean flag=false;

@AuraEnabled
public static Boolean getOpportunity(Id OppId) {
        system.debug('called get opportunity');
        system.debug('opportunity id' + OppId);
        Opportunity o = [Select Territory2Id from Opportunity where Id=:OppId];
        if(o.Territory2Id == NULL){
            flag=true;
            return flag;
        }
        return flag;

    }

@AuraEnabled(cacheable=true)
public static string getBaseURL(){
    String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
    prefix = prefix.removeEnd('--c');
    string baseURL = 'https://' + prefix.toLowerCase() + '.lightning.force.com';
    system.debug('returning value--->' + baseURL);
    return baseURL;
}


}