public with sharing class MobileOpptyFilterController {

  @AuraEnabled(cacheable=false)  
  public static List<sobject> findRecords(String searchKey, String objectName, String recordTypeId) {  
    string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
    string rText = '';
    string query = '';
    //System.debug('In find Records : '+searchKey+ ' Object: '+objectName);
    query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+' LIMIT 6';
    
    if (objectName == 'account')
      query = 'SELECT Id, Name FROM Account WHERE Name LIKE '+'\'%' + String.escapeSingleQuotes(searchKey) + '%\'' +' and RecordTypeId = \'012800000002AW5AAM\' LIMIT 6';

    if (objectName == 'Surgeon')
      query = 'SELECT Id, Name FROM Account WHERE Name LIKE '+'\'%' + String.escapeSingleQuotes(searchKey) + '%\'' +' and RecordTypeId = \'012800000002C4gAAE\' LIMIT 6';

    if (objectName == 'Territory2ForOpportunity')
      query = 'SELECT Id, Name FROM Territory2 WHERE Name LIKE '+'\'%' + String.escapeSingleQuotes(searchKey) + '%\'' +' and Name like \'%OPPORTUNITY%\' LIMIT 6';

      if (objectName == 'User')
      query = 'SELECT Id, Name FROM User WHERE (FirstName LIKE '+'\'%' + String.escapeSingleQuotes(searchKey) + '%\' OR LastName LIKE '+'\'%' + String.escapeSingleQuotes(searchKey) + '%\') LIMIT 6';

    System.debug('The Query '+query);

    return Database.query(query);
  }  

  @AuraEnabled(cacheable=true)  
  public static List<String> getUSOrthoRecordTypeIds() {  
    
    Map<String, String> recordTypeMap = Ortho_Util.getUSOrthoOpptyRecordTypes();

    Set<String> orthoRecordTypeSet = recordTypeMap.keySet();
    
    return (new List<String>(orthoRecordTypeSet));
  }

  @AuraEnabled(cacheable=true)  
  public static List<Opportunity> searchOpportunities(String acctId, String srgnId, String prdGrpId,String teamId, String cmptrId, String ownerId, Boolean bpTrgt, Boolean drvDfnd) {  
    //string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';
    
    System.debug('Finding Opportunities for Filters Account :'+acctId) ;
    
    Integer noOfFilters = 0;
    String recordTypeStr = '';

    /*Map<String, String> recordTypeMap = Ortho_Util.getUSOrthoOpptyRecordTypes();    
    Set<String> orthoRecordTypeSet = recordTypeMap.keySet();
    
    Integer i = 1;
    for (String s : orthoRecordTypeSet) 
    {
      recordTypeStr = recordTypeStr + '\''+s+'\'';
      if (i != orthoRecordTypeSet.size() ) {
      recordTypeStr = recordTypeStr + ',';
      }
      i++;
    }*/
    
    string query = 'SELECT Id, Name, Account.Name, StageName, Surgeon_Name__r.Name, Product_Group__c, Owner.Name, Territory2.Name, RecordType.Name, CloseDate FROM Opportunity WHERE ';

    /*if (String.isNotBlank(recordTypeStr)) {
      query = query + ' RecordTypeId in ('+recordTypeStr+ ')';
      noOfFilters++;
    }*/

    if (String.isNotBlank(acctId)) {
      if (noOfFilters > 0)
        query = query + ' and ';
        query = query + 'AccountId=\''+acctId+'\'';
        noOfFilters++;
    }

    if (String.isNotBlank(srgnId)){
      if (noOfFilters > 0)
        query = query + ' and ';
        query = query + 'Surgeon_Name__c =\''+srgnId+'\'';
    noOfFilters++;
    }

    if (String.isNotBlank(prdGrpId)){      
      String prd = prdGrpId.replace('[','').replace(']','').replace('"','\'');
      if (String.isNotBlank(prd))
      {
          if (noOfFilters > 0)
            query = query + ' and ';
        query = query + 'RecordTypeId in ('+prd+')';
        noOfFilters++;
      }
    }

    if (String.isNotBlank(teamId)){
      if (noOfFilters > 0)
        query = query + ' and ';
    query = query + 'Territory2Id=\''+teamId+'\'';
    noOfFilters++;
    }

    /*if (String.isNotBlank(cmptrId)){
      if (noOfFilters > 0)
        query = query + ' and ';
    query = query + 'Competitor__c=\''+cmptrId+'\'';
    noOfFilters++;
    }*/

    if (String.isNotBlank(cmptrId)){      
      String cmptr = cmptrId.replace('[','').replace(']','').replace('"','\'');
      if (String.isNotBlank(cmptr))
      {
          if (noOfFilters > 0)
            query = query + ' and ';
        query = query + 'Competitor__c in ('+cmptr+')';
        noOfFilters++;
      }
    }

    if (String.isNotBlank(ownerId)){
      if (noOfFilters > 0)
        query = query + ' and ';
    query = query + 'OwnerId=\''+ownerId+'\'';
    noOfFilters++;
    }

    //if (String.isNotBlank(bpTrgt)){
    if (bpTrgt==true) {
      if (noOfFilters > 0)
        query = query + ' and ';
    query = query + 'BP_Target__c='+bpTrgt;
    noOfFilters++;
    }

    //if (String.isNotBlank(drvDfnd)){
    if (drvDfnd==true) {
      if (noOfFilters > 0)
        query = query + ' and ';
    query = query + 'Drive_Defend__c='+drvDfnd;
    noOfFilters++;
    }

    query = query + ' Order by CloseDate desc NULLS FIRST LIMIT 500';
    System.debug('The Query '+query);

    /*query = 'SELECT Id, Name, StageName FROM Opportunity WHERE ';
    if (String.isNotBlank(acctId)) {
      query = query + 'AccountId=\''+acctId+'\'';
      noOfFilters++;
      }*/
    return Database.query(query);  
  }  
}