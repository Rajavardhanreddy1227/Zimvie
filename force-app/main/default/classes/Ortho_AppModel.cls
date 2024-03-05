/**
* @author Appirio Inc.
* @date Feb, 2020
*
* @group AppModels for Ortho
**/
public virtual class Ortho_AppModel{
    public class UserTerritoryAssociation{
        public String userId;
        public String terrtoryId;
        public String role;
        public UserTerritoryAssociation(String userId, String terrtoryId, String role){
            this.userId = userId;
            this.terrtoryId = terrtoryId;
            this.role = role;
        }
        public UserTerritoryAssociation(Object obj){
            UserTerritory2Association sObj;
            User_Territory_Association__c cObj;
            if(obj instanceOf UserTerritory2Association){
                sObj = (UserTerritory2Association) obj;
                this.userId = sObj.UserId;
                this.terrtoryId = sObj.Territory2Id;
                this.role = sObj.RoleInTerritory2;
            }else if(obj instanceOf User_Territory_Association__c){
                cObj = (User_Territory_Association__c) obj;
                this.userId = cObj.User__c;
                this.terrtoryId = cObj.Territory__C;
                this.role = cObj.Role__C;
            }

        }
    }


}