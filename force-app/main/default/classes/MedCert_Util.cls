public with sharing class MedCert_Util {
    public MedCert_Util() {
    }
    /*
    * @description This method creates Surgeon Med Certifications Records
    */
    public static void syncMedCertifications(List<Certification__c> lstCerts) {
        List<HCF_Surgeon_Certification__c> lstExistingCerts = new List<HCF_Surgeon_Certification__c>();
        List<Healthcare_Surgeon_Relationship__c> lstHCFs = new List<Healthcare_Surgeon_Relationship__c>();

        Set<Id> lstUnqSrgns = new Set<Id>();        
        
        Map<Id, Set<Id>> srgnCertMapNeeded = new Map<id, Set<Id>>();

        System.debug(lstCerts.size() + ' certifications');
        for (Certification__c c : lstCerts) {

            if (c.Contact__r.AccountId != null) {
                if(!srgnCertMapNeeded.containsKey(c.Contact__r.AccountId)){
                    srgnCertMapNeeded.put(c.Contact__r.AccountId, new Set<Id>());
                }
                
                srgnCertMapNeeded.get(c.Contact__r.AccountId).add(c.Id);

                lstUnqSrgns.add(c.Contact__r.AccountId);
            }
        }
        
        lstExistingCerts = [Select Id, Certification__c, Health_Care_Facility__c, Surgeon__c from HCF_Surgeon_Certification__c where Surgeon__c in :lstUnqSrgns];

        lstHCFs = [Select Id, Healthcare_Facility__c, Surgeon__c from Healthcare_Surgeon_Relationship__c where Surgeon__c in :lstUnqSrgns and Healthcare_Facility__c != null];

        Map<Id, Set<Id>> srgnCertMap = new Map<id, Set<Id>>();
        Map<Id, Set<Id>> srgnHCFMap = new Map<id, Set<Id>>();
        // We will create a Set of Srgn + '-' + Cert + '-' + HCF
        Set<String> currCertSet = new Set<String>(); 

        // Get All Current Cerifications
        for (HCF_Surgeon_Certification__c c : lstExistingCerts) {
            if(!srgnCertMap.containsKey(c.Surgeon__c)){
                srgnCertMap.put(c.Surgeon__c, new Set<Id>());
            }
            
            srgnCertMap.get(c.Surgeon__c).add(c.Certification__c);

            currCertSet.add(c.Surgeon__c + '-' + c.Certification__c + '-' + c.Health_Care_Facility__c);
        }

        // Get All Current Surgeon Relationships
        for (Healthcare_Surgeon_Relationship__c hcf : lstHCFs) {
            if(!srgnHCFMap.containsKey(hcf.Surgeon__c)){
                srgnHCFMap.put(hcf.Surgeon__c, new Set<Id>());
            }
            
            srgnHCFMap.get(hcf.Surgeon__c).add(hcf.Healthcare_Facility__c);
        }

        
        System.debug('There are '+lstUnqSrgns.size() + ' unique surgeons');
        
        System.debug(currCertSet);
        //List<SrgnCertHCF> lstToAdd = new List<SrgnCertHCF>();
        List<HCF_Surgeon_Certification__c> lstToAdd = new List<HCF_Surgeon_Certification__c>();
        List<HCF_Surgeon_Certification__c> lstToDelete = new List<HCF_Surgeon_Certification__c>();

        // Identify List of Certification Records to be created/deleted
        for (String s : lstUnqSrgns) {
            Set<Id> certs = srgnCertMapNeeded.get(s);
            Set<Id> hcfs = srgnHCFMap.get(s);

            if (certs != null) {
                for (String c : certs) {
                    if (hcfs != null) {
                        for (String h : hcfs) {
                            if (!currCertSet.contains(s + '-' + c + '-' + h))
                                lstToAdd.add(new HCF_Surgeon_Certification__c(Surgeon__c=s, Certification__c = c, Health_Care_Facility__c = h));
                        }
                    }
                }
            }
        }

        // Now find the list to delete
        for (HCF_Surgeon_Certification__c c : lstExistingCerts) {
            if (c.Health_Care_Facility__c != null) {
                Set<Id> srgnHCF = srgnHCFMap.get(c.Surgeon__c);

                if(srgnHCF == null || !srgnHCF.contains(c.Health_Care_Facility__c)){
                    System.debug('Did not find Surgeon '+c.Surgeon__c + ' with HCF Facility : '+c.Health_Care_Facility__c+'. It will be deleted');
                    lstToDelete.add(new HCF_Surgeon_Certification__c(Id=c.Id));
                }
            }
        }

        System.debug('Surgeon Certification Records Added : '+lstToAdd.size());
        System.debug('Surgeon Certification Records Deleted : '+lstToDelete.size());

        System.debug(lstToAdd);
        System.debug(lstToDelete);

        if(!lstToAdd.isEmpty()){
            insert lstToAdd;
        }

        if(!lstToDelete.isEmpty()){
            delete lstToDelete;
        }
    }
}