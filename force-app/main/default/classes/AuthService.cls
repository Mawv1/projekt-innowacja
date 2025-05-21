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
    private static final String CLIENT_ID = '3MVG9xqN3LZmHU7n7G0NHUYpNLMsh55X1HNRUcsBJ5Dtevv.S1jOSgyx3l3DQXqRc1md0qpR_l7ewk1oK4Oa9';
    private static final String SECRET = 'F5CF486958B3E03C7FEF2A26DDB959301FCD7CDF34F3736F51A409D5B378402F';
    private static final String USERNAME = 'restuser@innowacja.rest.rest';
    private static final String PASSWORD = 'testInn123!';
    private static final String SECURITY_TOKEN = '7Z6ATDMvnnmfXwEpVa9PqgAG';

    public static String getAccessToken() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(ENDPOINT);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body = 
            'grant_type=password' +
            '&client_id=' + EncodingUtil.urlEncode(CLIENT_ID, 'UTF-8') +
            '&client_secret=' + EncodingUtil.urlEncode(SECRET, 'UTF-8') +
            '&username=' + EncodingUtil.urlEncode(USERNAME, 'UTF-8') +
            '&password=' + EncodingUtil.urlEncode(PASSWORD + SECURITY_TOKEN, 'UTF-8');

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
