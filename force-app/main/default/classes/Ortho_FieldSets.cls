public class Ortho_FieldSets {

 
    private static Schema.DescribeSObjectResult[] describeObjects(List<String> sObjects){
        return Schema.describeSObjects(sObjects);
    }


    @AuraEnabled(cacheable=true)
    public static Ortho_FieldSetMember[] getFieldsetByObjectAndName(String sObjectName, String fieldSetName){
        Schema.DescribesObjectResult[] descResults = describeObjects(new List<String> {sObjectName});
        List<Ortho_FieldSetMember> fieldSetMembers =  new List<Ortho_FieldSetMember>();
        if(descResults.size() > 0){
            Schema.DescribeSObjectResult sObjDescribe = descResults[0];
            Schema.FieldSet fieldSet = sObjDescribe.fieldsets.getMap().get(fieldSetName);

            for(Schema.FieldSetMember fsm : fieldSet.getFields()){
                fieldSetMembers.add(new Ortho_FieldSetMember(sObjectName, fsm));
            }

        }

        return fieldSetMembers;
    }
    
    public class Ortho_FieldSetMember {
        @AuraEnabled
        public Boolean dBRequired {
            get{
                return this.fieldSetMember.getDBRequired();
            }
        }
        @AuraEnabled
        public String fieldPath {
            get{
                return this.fieldSetMember.getFieldPath();
            }
        }
        @AuraEnabled
        public String label {
            get{
                return this.fieldSetMember.getLabel();
            }
        }
        @AuraEnabled
        public Boolean required {
            get{
                return this.fieldSetMember.getRequired();
            }
        }
        @AuraEnabled
        public String fieldType {
            get{
                return this.fieldSetMember.getType().name();
            }
        }
        @AuraEnabled
        public String fullName {
            get{
               
                return this.sObjectName + '.' + this.fieldPath;
            }
        }

        @AuraEnabled
        public string relationshipPath{
            get {
                Schema.DescribeFieldResult dfr = this.fieldSetMember.getSObjectField().getDescribe();
                if(dfr.getType() == Schema.DisplayType.REFERENCE){
                    return this.sObjectName + '.' + dfr.getRelationshipName() + '.Name';
                }
                return null;
            }
        }

        private String sObjectName;
        private Schema.FieldSetMember fieldSetMember;
        public Ortho_FieldSetMember(String sObjectName, Schema.FieldSetMember fieldSetMember){
            this.sObjectName = sObjectName;
            this.fieldSetMember = fieldSetMember;
        }

    }
}