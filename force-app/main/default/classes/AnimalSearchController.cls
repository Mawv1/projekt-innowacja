public with sharing class AnimalSearchController {

    @AuraEnabled(cacheable=true)
    public static List<Animal__c> getAnimals(String shelter, String breed, String age, String gender) {
        String query = 'SELECT Id, Name, Breed__c, Age__c, Shelter__r.Name, Shelter__c, Sex__c, Photo_URL__c FROM Animal__c WHERE ';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(shelter)) {
            conditions.add('Shelter__r.Name = :shelter');
        }
        if (String.isNotBlank(breed)) {
            conditions.add('Breed__c = :breed');
        }
        if (String.isNotBlank(age)) {
            Integer ageValue;
            try {
                ageValue = Integer.valueOf(age);
            } catch (Exception e) {
                ageValue = null;
            }
            conditions.add('Age__c = :ageValue');
        }
        if (String.isNotBlank(gender)) {
            conditions.add('Sex__c = :gender');
        }

        if (conditions.isEmpty()) {
            query = query.removeEnd(' WHERE ') + ' LIMIT 50';
        } else {
            query += String.join(conditions, ' AND ');
        }

        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getShelterOptions() {
        Set<String> shelters = new Set<String>();
        for (Animal__c animal : [SELECT Shelter__r.Name FROM Animal__c WHERE Shelter__c != null]) {
            if (animal.Shelter__r != null) {
                shelters.add(animal.Shelter__r.Name);
            }
        }
        return new List<String>(shelters);
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getBreedOptions() {
        Set<String> breeds = new Set<String>();
        for (Animal__c animal : [SELECT Breed__c FROM Animal__c WHERE Breed__c != null]) {
            breeds.add(animal.Breed__c);
        }
        return new List<String>(breeds);
    }

    @AuraEnabled(cacheable=true)
    public static List<Integer> getAgeOptions() {
        List<Integer> ages = new List<Integer>();
        for (Animal__c animal : [SELECT Age__c FROM Animal__c WHERE Age__c != null ORDER BY Age__c]) {
            Integer ageVal = animal.Age__c != null ? animal.Age__c.intValue() : null;
            if (ageVal != null && !ages.contains(ageVal)) {
                ages.add(ageVal);
            }
        }
        return ages;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getGenderOptions() {
        Set<String> genders = new Set<String>();
        for (Animal__c animal : [SELECT Sex__c FROM Animal__c WHERE Sex__c != null]) {
            genders.add(animal.Sex__c);
        }
        return new List<String>(genders);
    }
}