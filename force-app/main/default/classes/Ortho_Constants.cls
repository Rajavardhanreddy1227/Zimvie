/**
* @author Appirio Inc.
* @date Feb, 2020
*
* @group Ortho_Constants
*
* @description This class inclueds all the contants which are utilized across multiple ortho classes
*/
public class Ortho_Constants {
    public static final String PRODUCT_ROLE_MAPPING = 'Product Role Mapping';
    public static final Map<String, String> OPP_RECORD_TYPE_MAP_BY_PRODUCT = Ortho_SettingsService.getGeneralSettingValueByType(PRODUCT_ROLE_MAPPING);

    public static final String TEAM_MEMBER_ROLE = 'Team_Member_Roles';
    
    public static final String SALES_MANAGER = 'Sales Manager';
    public static final String TEAM_LEAD = 'Team Lead';
    public static final String TERRITORY_LEAD = 'Territory Lead';
    public static final String NON_SENIOR_REP = 'Non-Senior Rep';
    public static final String SENIOR_REP = 'Senior Rep';
    public static final String PRODUCT_SPECIALIST = 'Product Specialist';
    public static final String US_ORTHO = 'US Ortho';
	public static final String OPP_OWNER_ROLE = 'Opportunity Owner';
    public static final Set<String> SKIP_PROFILE_SET = new Set<String>{'System Administrator'};

}