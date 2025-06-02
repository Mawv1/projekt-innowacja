public with sharing class AnimalSearchController {
    private static final Integer PAGE_SIZE = 10;

    @AuraEnabled(cacheable=true)
    public static List<Animal__c> getAnimals(
        String shelter,
        String breed,
        Integer age,
        String gender,
        Integer offset
    ) {
        if (offset == null) {
            offset = 0;
        }

        List<String> conditions = new List<String>();
        if (String.isNotBlank(shelter)) {
            conditions.add('Shelter__r.Name = :shelter');
        }
        if (String.isNotBlank(breed)) {
            String likeBreed = '%' + breed + '%';
            conditions.add('Breed__c LIKE :likeBreed');
        }
        if (age != null) {
            conditions.add('Age__c = :age');
        }
        if (String.isNotBlank(gender)) {
            conditions.add('Sex__c = :gender');
        }

        String baseQuery = 
            'SELECT Id, Name, Breed__c, Age__c, Photo_URL__c, Sex__c, Shelter__r.Name ' +
            'FROM Animal__c';

        if (!conditions.isEmpty()) {
            baseQuery += ' WHERE ' + String.join(conditions, ' AND ');
        }

        baseQuery += ' LIMIT ' + PAGE_SIZE;
        baseQuery += ' OFFSET ' + offset;

        return Database.query(baseQuery);
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getShelterOptions() {
        List<String> shelterNames = new List<String>();
        for (Shelter__c shelter : [SELECT Name FROM Shelter__c]) {
            shelterNames.add(shelter.Name);
        }
        return shelterNames;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getGenderOptions() {
        List<String> genderOptions = new List<String>();
        Schema.DescribeFieldResult fieldResult = Animal__c.Sex__c.getDescribe();

        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            if (!entry.isActive()) continue;
            genderOptions.add(entry.getLabel());
        }

        return genderOptions;
    }
}