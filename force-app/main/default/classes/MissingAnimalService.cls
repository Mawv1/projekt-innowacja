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

    public static List<AnimalWrapper> getMissingAnimals(Integer dayDelta) {
        if (dayDelta == null) {
            dayDelta = 7;
        }
        if (dayDelta < 0) {
            throw new AuraHandledException('Day delta cannot be negative');
        }

        Date targetDate = Date.today().addDays(-dayDelta);
        System.debug(targetDate);

        String token = AuthService.getAccessToken();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT);
        request.setMethod(GET);
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            List<AnimalWrapper> unsortedAnimalsList = (List<AnimalWrapper>) JSON.deserialize(response.getBody(), List<AnimalWrapper>.class);
            
            for (AnimalWrapper animalWrapper : unsortedAnimalsList) {
                System.debug(animalWrapper.missingDate);
            }

            List<AnimalWrapper> animalsList = new List<AnimalWrapper>();

            for (AnimalWrapper animalWrapper : unsortedAnimalsList) {
                System.debug(animalWrapper.getMissingDate());
                if (animalWrapper.getMissingDate() >= targetDate) {
                    animalsList.add(animalWrapper);
                }
            }

            return animalsList;
        } else {
            throw new CalloutException('Failed to get data from ' + ENDPOINT + ' status:' + response.getStatus());
        }
    }
}