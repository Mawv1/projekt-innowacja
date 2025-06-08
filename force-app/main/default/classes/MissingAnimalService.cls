public with sharing class MissingAnimalService {
    private static final String ENDPOINT = 'https://cw-inn--rest.sandbox.my.salesforce.com/services/apexrest/MissingAnimals';
    private static final String GET = 'GET';
    private static final String POST = 'POST';
    
    public class AnimalWrapper {
       @AuraEnabled public String id {get; set;}
       @AuraEnabled public String missingDate {get; set;}
       @AuraEnabled public String name {get; set;}

        public Date getMissingDate() {
            return Date.valueOf(missingDate.substring(0,10));
        }
    }

    public class AnimalDetailWrapper {
       @AuraEnabled public String id {get; set;}
       @AuraEnabled public String name {get; set;}
       @AuraEnabled public String missingDate {get; set;}
       @AuraEnabled public String imageUrl {get; set;}

        public Date getMissingDate() {
            return Date.valueOf(missingDate.substring(0,10));
        }
    }

    @AuraEnabled(cacheable=false)
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

    @AuraEnabled(cacheable=false)
    public static AnimalDetailWrapper getMissingAnimalDetails(String id) {
        if (id == null) {
            throw new InvalidParameterException('Id cannot be null');
        }

        // if (!id.substring(0,4).equals('ANO-')) {
        //     throw new InvalidParameterException('Wrong Id format');
        // }

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

    
    public class MissingAnimalWrapper {
       @AuraEnabled public ReportWrapper report {get; set;}
       @AuraEnabled public AnimalCreateWrapper animal {get; set;}
    }

    public class ReportWrapper {
       @AuraEnabled public String address {get; set;}
       @AuraEnabled public Decimal disappearancePlaceLongitude {get; set;}
       @AuraEnabled public Decimal disappearancePlaceLatitude {get; set;}
       @AuraEnabled public String disappearanceDate {get; set;}
       @AuraEnabled public String description {get; set;}
    }

    public class AnimalCreateWrapper {
       @AuraEnabled public String name {get; set;}
       @AuraEnabled public String imageUrl {get; set;}
       @AuraEnabled public String breed {get; set;}
       @AuraEnabled public Integer age {get; set;}
       @AuraEnabled public String uniqueFeatures {get; set;}
       @AuraEnabled public String size {get; set;}
    }

    @AuraEnabled(cacheable=true)
    public static void createMissingAnimal(MissingAnimalWrapper wrapper) {
        if (wrapper == null || wrapper.report == null || wrapper.animal == null) {
            throw new AuraHandledException('Brak wymaganych danych');
        }

        Boolean hasAddress = !String.isBlank(wrapper.report.address);
        Boolean hasCoords = wrapper.report.disappearancePlaceLatitude != null && wrapper.report.disappearancePlaceLongitude != null;
        if (!hasAddress && !hasCoords) {
            throw new AuraHandledException('Wymagany jest adres lub współrzędne');
        }

        if (String.isBlank(wrapper.report.disappearanceDate) || String.isBlank(wrapper.report.description)) {
            throw new AuraHandledException('Data zaginięcia i opis są wymagane');
        }

        String token = AuthService.getAccessToken();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT);
        request.setMethod(POST);
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');

        String jsonBody = JSON.serialize(new Map<String, Object>{ 'missingAnimalWrapper' => wrapper });
        request.setBody(jsonBody);

        HttpResponse response = http.send(request);

        if (response.getStatusCode() != 201 && response.getStatusCode() != 200) {
            throw new CalloutException('Błąd przy tworzeniu zgłoszenia: ' + response.getStatus() + ' ' + response.getBody());
        }
    }

    public class UpdateAnimalFoundWrapper {
       @AuraEnabled public String animalId {get; set;}
       @AuraEnabled public Boolean found {get; set;}
    }

    @AuraEnabled(cacheable=true)
    public static void updateAnimalFoundStatus(String animalId, Boolean found) {
        if (String.isBlank(animalId)) {
            throw new AuraHandledException('animalId nie może być pusty');
        }
        if (found == null) {
            throw new AuraHandledException('found nie może być pusty');
        }

        // if (!animalId.startsWith('ANO-')) {
        //     throw new AuraHandledException('Nieprawidłowy format animalId');
        // }

        String token = AuthService.getAccessToken();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT);
        request.setMethod('PUT');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');

        UpdateAnimalFoundWrapper payload = new UpdateAnimalFoundWrapper();
        payload.animalId = animalId;
        payload.found = found;

        String jsonBody = JSON.serialize(payload);
        request.setBody(jsonBody);

        HttpResponse response = http.send(request);

        if (response.getStatusCode() != 200 && response.getStatusCode() != 204) {
            throw new CalloutException('Błąd przy aktualizacji statusu: ' + response.getStatus() + ' ' + response.getBody());
        }
    }
}