public class OAuthRefreshTokenGenerator {
    
    //sample class
    // Replace these values with your actual client credentials
    private static final String CLIENT_ID = '3MVG9ooRt4uZ_3TkuLtDdHm0EvqdBi5K8HPQMAZFUAeA41c9CMxyVZ0VTEdSqyVGlvFrUYokRypRWoaewnGH3';
    private static final String CLIENT_SECRET = '38CE6817671C5E5285CCABF9AA0B8168A837019AA84EADA9436046ECD0999BD0';
    private static final String REFRESH_TOKEN_ENDPOINT = 'https://zimvieglobal--ecommerce.sandbox.my.salesforce.com/services/oauth2/token';

    public static void generateRefreshToken() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(REFRESH_TOKEN_ENDPOINT);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        String body = 'grant_type=refresh_token' +
                      '&client_id=' + EncodingUtil.urlEncode(CLIENT_ID, 'UTF-8') +
                      '&client_secret=' + EncodingUtil.urlEncode(CLIENT_SECRET, 'UTF-8') +
                      '&refresh_token=' + EncodingUtil.urlEncode('your_refresh_token', 'UTF-8');
        request.setBody(body);
        
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String newAccessToken = (String) jsonResponse.get('access_token');
            String newRefreshToken = (String) jsonResponse.get('refresh_token');
            
            System.debug('New Access Token: ' + newAccessToken);
            System.debug('New Refresh Token: ' + newRefreshToken);
        } else {
            System.debug('Error refreshing token. Status code: ' + response.getStatusCode());
            System.debug('Response Body: ' + response.getBody());
        }
    }
}