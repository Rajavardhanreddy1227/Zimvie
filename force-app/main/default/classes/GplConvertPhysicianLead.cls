global with sharing class GplConvertPhysicianLead {    	 
    webservice static String convertLead(Id leadId) {
        GplDataManager manager = new GplDataManager();
        return manager.createPhysicianFromLead(leadId);
    }
}