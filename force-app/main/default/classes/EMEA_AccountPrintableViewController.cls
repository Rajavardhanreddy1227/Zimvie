/********************************************************************************* 
* @author         Madalina Chirita (Deloitte Digital)
* @description    Controller class for Visualforce page EMEA_AccountPrintableView (US-0283)
* @date	          2021-10-12
**********************************************************************************/ 
public class EMEA_AccountPrintableViewController {
    
    private final Account account;
    
    public EMEA_AccountPrintableViewController(ApexPages.StandardController controller) {
   		this.account = (Account)controller.getRecord();
    }
    

/********************************************************************************
* @author		Madalina Chirita (Deloitte Digital)
* @date			2021-10-12
* @description  Get the Account record (US-0283)
* @return		Account: the current record
********************************************************************************/
    public Account getAccountInfo() {
		return account;
	}
       
/********************************************************************************
* @author		Madalina Chirita (Deloitte Digital)
* @date			2021-10-12
* @description  Get the Partners name and roles for account record (US-0283)
* @return		List<Partner>: current record partners
********************************************************************************/
    public List<Partner> getPartners(){
        
       List<Partner> partnerList = [SELECT AccountTo.Name, Role 
                                    FROM Partner
                                    WHERE AccountFromId =:account.Id AND Role IN ('Buying Group','Member - Hospital')
                                    ORDER BY Role];
       return partnerList;
    }
    
/********************************************************************************
* @author		Madalina Chirita (Deloitte Digital)
* @date			2021-10-12
* @description  Get Team Members name and roles for account record (US-0283)
* @return		List<AccountTeamMember>: current record account team
********************************************************************************/
    public List<AccountTeamMember> getTeamMembers(){
        
        List<AccountTeamMember> teamMembers = [SELECT UserId, User.Name, TeamMemberRole
                                               FROM AccountTeamMember
                                               WHERE AccountId=:account.Id
                                               ORDER BY TeamMemberRole];
        return teamMembers;
    }
    

/********************************************************************************
* @author		Madalina Chirita (Deloitte Digital)
* @date			2021-10-12
* @description  Get the Segmentation details for the account record (US-0283)
* @return		List<EMEA_Account_Segmentation__c>: current account segmentation
********************************************************************************/
    public List<EMEA_Account_Segmentation__c> getAccountSegmentation(){
        
        List<EMEA_Account_Segmentation__c> accountSegmentation = [SELECT EMEA_Business_Unit__c, EMEA_Business_Segment__c,EMEA_Avalanche_Segment__c, EMEA_Impact__c, EMEA_Year__c 
                                                                  FROM EMEA_Account_Segmentation__c 
                                                                  WHERE EMEA_Account__c =:account.Id
                                                                  ORDER BY EMEA_Business_Unit__c, EMEA_Year__c];
        return accountSegmentation;
    }
    

/********************************************************************************
* @author		Madalina Chirita (Deloitte Digital)
* @date			2021-10-12
* @description  Get Opportunity details for current account record (US-0283)
* @return		List<Opportunity>: current record opportunities
********************************************************************************/
    public List<Opportunity> getOpportunities(){
        
       List<Opportunity> opportunities = [SELECT Name, Type, StageName, CloseDate, Probability, Amount
                                          FROM Opportunity 
                                          WHERE AccountId=:account.Id
                                          ORDER BY StageName, Type];
        return opportunities;
    }
    
    
/********************************************************************************
* @author		Madalina Chirita (Deloitte Digital)
* @date			2021-10-12
* @description  Get Account Plan details, Objectives and Tactics for account record (US-0283)
* @return		List<EMEA_Account_Plan__C>: current record account plans
********************************************************************************/
    public List<EMEA_Account_Plan__c>  getAccountPlans() {
 
        List<EMEA_Account_Plan__c> accountPlans = [SELECT Name, EMEA_Status__c, EMEA_Account_Plan_Name__c, EMEA_Business_Segment__c, EMEA_Business_Unit__c,
                                              		EMEA_Target_Revenue__c, EMEA_End_Date__c,
      												(SELECT Name, EMEA_Type__c FROM Objectives__r ),
                                                	(SELECT Name , EMEA_Next_Step__c, EMEA_Objective__c FROM Tactics__r)
          										   FROM EMEA_Account_Plan__c 
                                                   WHERE EMEA_Account__c =:account.Id
                                                   ORDER BY EMEA_Business_Unit__c, EMEA_Status__c, Name];
        return accountPlans;  
    }
    
    
/********************************************************************************
* @author		Madalina Chirita (Deloitte Digital)
* @date			2021-10-12
* @description  Get Contact details for the current account record (US-0283)
* @return		List<Contact>: current record associated contacts
********************************************************************************/
    public List<Contact> getContacts(){
        
        Set<String> keyContacts = new Set<String>();
		keyContacts.add('%Chief%');
        keyContacts.add('%Director%');
        keyContacts.add('%Lead%');
        keyContacts.add('%Head%');
        keyContacts.add('%General%');

        
        List<Contact> contacts = [SELECT Name, EMEA_Function__c, Department
                                  FROM Contact
                                  WHERE AccountId=:account.Id AND EMEA_Function__c LIKE :keyContacts
                                  ORDER BY EMEA_Function__c, Department, Name];
        return contacts;
    }
    

/********************************************************************************
* @author		Madalina Chirita (Deloitte Digital)
* @date			2021-10-12
* @description  Get Competitor Analysis details for account record (US-0283)
* @return		List<EMEA_Competitor_Analysis__c>: current record competitor analysis
********************************************************************************/
    public List<EMEA_Competitor_Analysis__c> getCompetitorAnalysis(){
        
        List<EMEA_Competitor_Analysis__c> analyses = [SELECT EMEA_Product__r.Name, EMEA_Competitor__c, EMEA_Segment__c, EMEA_Surgeries_per_Year__c 
                                                     FROM EMEA_Competitor_Analysis__c 
                                                     WHERE EMEA_Account__c=:account.Id
                                                     ORDER BY EMEA_Segment__c,EMEA_Competitor__c, EMEA_Product__r.Name];
        return analyses; 
    }
}