global with sharing class GplConvertClinicLead {    	 
    webservice static String convertLead(Id leadId) {
        GplDataManager manager = new GplDataManager();
        return manager.createClinicFromLead(leadId);
    }
}