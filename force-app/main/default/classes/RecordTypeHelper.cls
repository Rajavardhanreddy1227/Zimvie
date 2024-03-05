/*
Description: Retrival of record type ids in 1 query. 
ALL other apex classes should be calling this class to retrieve record type ids. 
*/

public class RecordTypeHelper {

  // internal static variables and methods
  private static Map<String, RecordType> m_rt = null;
  private static void fillRecordTypeMap() {
    m_rt = new Map<String, RecordType>();
        //RecordType[] rtList = [Select Id, sObjectType, Name From RecordType];
        RecordType[] rtList = [Select Id, sObjectType, Name, DeveloperName From RecordType];
        for(RecordType rt : rtList) {
          //m_rt.put(rt.sObjectType + '|' + rt.Name, rt);
          m_rt.put(rt.sObjectType + '|' + rt.DeveloperName, rt);
          m_rt.put(rt.Id, rt);
        }
  }
  // public methods
    public static Id getRecordTypeId(String sobject_type, String recordtype_name) {
       RecordType rt = getRecordType(sobject_type, recordtype_name);
       return (rt!=null?rt.Id:null);
    }
    public static RecordType getRecordType(String sobject_type, String recordtype_name) {
       if(m_rt==null || m_rt.size()==0) 
          fillRecordTypeMap();
        RecordType rt = m_rt.get(sobject_type + '|' + recordtype_name);
        return (rt!=null?rt:null);
    }
    public static String getRecordTypeName(Id recordtype_id) {
        System.debug('XZZZZZZ' + recordtype_id);
      if(m_rt==null || m_rt.size()==0)
        fillRecordTypeMap();
      RecordType rt = m_rt.get(recordtype_id);
        System.debug('@@@@@RTYPEID' + recordtype_id);
      return (rt!=null?rt.Name:null);
    }
     
}