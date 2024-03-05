public with sharing class Zimvie_recordlistController {
        @AuraEnabled(cacheable=true)
        public static DataTableResponse loadRecords(String objectApiName, String fieldsName)
        {
            String query = 'SELECT '+fieldsName+' FROM '+objectApiName;
            List<SObject> lstDataTableData = Database.query(query);
            
            List<String> fieldApiNames = fieldsName.split(',');
            List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
            Map<String,String> fieldApiLabelMap = getMyAPINameMap(objectApiName,fieldApiNames);
            for(String apiLabelMap : fieldApiLabelMap.keySet()){
                DataTableColumns datacolumns = new DataTableColumns(fieldApiLabelMap.get(apiLabelMap),apiLabelMap);
                lstDataColumns.add(datacolumns);
            }
            
            DataTableResponse finalWrapper   = new DataTableResponse();
            finalWrapper.lstDataTableColumns = lstDataColumns;
            finalWrapper.lstDataTableData    = lstDataTableData;
            return finalWrapper;
        }
    
       public class DataTableColumns {
            @AuraEnabled
            public String label {get;set;}
            @AuraEnabled       
            public String fieldName {get;set;}
           
            public DataTableColumns(String label, String fieldName)
            {
                this.label     = label;
                this.fieldName = fieldName;    
            }
        }
        
        public class DataTableResponse {
            @AuraEnabled
            public List<DataTableColumns> lstDataTableColumns {get;set;}
            @AuraEnabled
            public List<sObject> lstDataTableData {get;set;}     
        }

        public static Map<String,String> getMyAPINameMap(String objectApiName, List<String> fieldApiNames) {
        	Map<String,String> fieldAPILabelMap = new Map<String,String>();    
        	SObjectType type = Schema.getGlobalDescribe().get(objectApiName);
        	Map<String,Schema.SObjectField> mfields = type.getDescribe().fields.getMap();	
        	for(String strField : fieldApiNames)
        	{
            	fieldAPILabelMap.put(strField,mfields.get(strField).getDescribe().getlabel()); 
        	}
        	return fieldAPILabelMap;   
        }

}