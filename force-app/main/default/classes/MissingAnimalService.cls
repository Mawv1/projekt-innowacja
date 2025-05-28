public with sharing class MissingAnimalService {
    private static final String ENDPOINT = 'https://cw-inn--rest.sandbox.my.salesforce.com/services/apexrest/MissingAnimals';
    private static final String GET = 'GET';
    private static final String POST = 'POST';
    
    public class AnimalWrapper {
        public String id;
        public String missingDate;
        public String name;

        public Date getMissingDate() {
            return Date.valueOf(missingDate.substring(0,10));
        }
    }

    public class AnimalDetailWrapper {
        public String id;
        public String name;
        public String missingDate;
        public String imageUrl;

        public Date getMissingDate() {
            return Date.valueOf(missingDate.substring(0,10));
        }
    }

    public static List<AnimalWrapper> getMissingAnimals(Integer dayDelta) {
        if (dayDelta == null) {
            dayDelta = 7;
        }
        if (dayDelta < 0) {
            throw new InvalidParameterException('Day delta cannot be negative');
        }

        Date targetDate = Date.today().addDays(-dayDelta);

        String token = AuthService.getAccessToken();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT + '?dayDelta=' + dayDelta);
        request.setMethod(GET);
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            List<AnimalWrapper> animalsList = (List<AnimalWrapper>) JSON.deserialize(response.getBody(), List<AnimalWrapper>.class);

            return animalsList;
        } else {
            throw new CalloutException('Failed to get data from ' + ENDPOINT + ' status:' + response.getStatus());
        }
    }

    public static AnimalDetailWrapper getMissingAnimalDetails(String id) {
        if (id == null) {
            throw new InvalidParameterException('Id cannot be null');
        }

        if (!id.substring(0,4).equals('ANO-')) {
            throw new InvalidParameterException('Wrong Id format');
        }

        String token = AuthService.getAccessToken();

         Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT + '/' + id);
        request.setMethod(GET);
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            AnimalDetailWrapper animal = (AnimalDetailWrapper) JSON.deserialize(response.getBody(), AnimalDetailWrapper.class);

            return animal;
        } else {
            throw new CalloutException('Failed to get data from ' + ENDPOINT + ' status:' + response.getStatus());
        }
    }
}