public with sharing class ShelterMapController {
    @AuraEnabled(cacheable=true)
    public static List<Shelter__c> getSheltersInSameCity(Id shelterId) {
        Shelter__c current = [SELECT Id, Name, City__c FROM Shelter__c WHERE Id = :shelterId LIMIT 1];

        return [
            SELECT Id, Name, City__c, Location__Latitude__s, Location__Longitude__s, Address__c, Email__c, Phone__c
            FROM Shelter__c
            WHERE City__c = :current.City__c
        ];
    }
}