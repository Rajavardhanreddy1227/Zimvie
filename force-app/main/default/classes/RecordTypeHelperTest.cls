@isTest
public class RecordTypeHelperTest {
  
           
    private static Map<String, RecordType> m_rt = null;
    
      public static Id getRecordTypeId(String sobject_type, String recordtype_name) 
    {
        m_rt = new Map<String, RecordType>();
       Id RecordTypeId= RecordTypeHelper.getRecordTypeId('Account','Distributor');
       return RecordTypeId;
    }
   
    
    // for test coverage
   
    static testmethod void RecordTypeHelper_TEST() 
    {
   
    //System.assertEquals(getRecordType('Account','Error Value'),null);
    //System.assertEquals(getRecordType('Account','Distributor'),[Select r.SobjectType, r.Name, r.DeveloperName From RecordType r where Name='Distributor' and SObjectType='Account']);    
    //System.assertEquals(getRecordTypeId('Account','Error Value'),null);
    System.assertEquals(getRecordTypeId('Account','Distributor'),[Select r.SobjectType, r.Name, r.DeveloperName From RecordType r where Name='Distributor' and SObjectType='Account'].Id);
    
   //System.assertEquals(getRecordTypeName(getRecordTypeId('Account','Error Value')),null);
   //System.assertEquals('Distributor',getRecordTypeName([Select r.SobjectType, r.Name From RecordType r where Name='Distributor' and SObjectType='Account'].Id));
    
    }
    }