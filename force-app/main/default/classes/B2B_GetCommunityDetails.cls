public class B2B_GetCommunityDetails {
    
    @InvocableMethod(label='getCommunityURL' description='getCommunityURL' category='Account')
    public static List<String> getCommunityURL() {
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        List<String> lstStr = new List<String>();
        try {
            Site site = [SELECT Id FROM Site WHERE UrlPathPrefix = 'Zimvie' LIMIT 1];
        
            String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
            
            System.debug('Community url: ' + communityUrl);
            
            lstStr.add(communityUrl);
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        
        return lstStr;
    }
}