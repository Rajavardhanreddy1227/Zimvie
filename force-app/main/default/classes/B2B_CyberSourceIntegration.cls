public class B2B_CyberSourceIntegration {
    private static final String clientId = '7c31f306-e0eb-4419-bb2b-df97524abaa5';
    private static final String clientSecret = 'bcWFgrlEKzwDKcuF1pkNw+Lk024viVBqYVouD+K/Cpw=';
    private static final String authEndpoint = 'https://auth.cybersource.com/oauth/token';
    private static final String jwkEndpoint = 'https://flex.cybersource.com/flex/v1/keys';

    @AuraEnabled(cacheable=true)
    public static String fetchToken() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(authEndpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody('client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8') +
                        '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8') +
                        '&grant_type=client_credentials');

        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            Map<String, Object> tokenResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            String accessToken = (String)tokenResponse.get('access_token');
            return fetchJWK(accessToken);
        } else {
            throw new AuraHandledException('Failed to fetch token: ' + response.getStatus());
        }
    }

    public static String fetchJWK(String accessToken) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(jwkEndpoint);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + accessToken);

        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            return response.getBody();
        } else {
            throw new AuraHandledException('Failed to fetch JWK: ' + response.getStatus());
        }
    }
}