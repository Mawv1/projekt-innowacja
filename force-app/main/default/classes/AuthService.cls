public with sharing class AuthService {
    public class TokenWrapper {
        public String access_token;
        public String instance_url;
        public String id;
        public String token_type;
        public String issued_at;
        public String signature;
    }

    private static final String ENDPOINT = 'https://test.salesforce.com/services/oauth2/token';

    private static String MOCK_ACCESS_TOKEN;

    public static void setMockAccessToken(String token) {
        MOCK_ACCESS_TOKEN = token;
    }

    public static String getAccessToken() {
        if (MOCK_ACCESS_TOKEN != null) {
            return MOCK_ACCESS_TOKEN;
        }

        Auth_Settings__c authSettings = Auth_Settings__c.getOrgDefaults();

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(authSettings.Endpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body = 
            'grant_type=password' +
            '&client_id=' + EncodingUtil.urlEncode(authSettings.Client_Id__c, 'UTF-8') +
            '&client_secret=' + EncodingUtil.urlEncode(authSettings.Secret__c, 'UTF-8') +
            '&username=' + EncodingUtil.urlEncode(authSettings.Username__c, 'UTF-8') +
            '&password=' + EncodingUtil.urlEncode(authSettings.Password__c + authSettings.Security_Token__c, 'UTF-8');

        request.setBody(body);
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            TokenWrapper token = (TokenWrapper) JSON.deserialize(response.getBody(), TokenWrapper.class);
            return token.access_token;
        } else {
            throw new CalloutException('Failed to authenticate: ' + response.getStatus() + ' - ' + response.getBody());
        }
    }
}