public with sharing class ShelterMapController {
    @AuraEnabled(cacheable=true)
    public static List<Shelter__c> getSheltersInSameCity(Id shelterId) {
        Shelter__c current = [SELECT Address__City__s FROM Shelter__c WHERE Id = :shelterId LIMIT 1];
        
        return [
            SELECT Id, Name, Address__Street__s, Address__City__s, Address__PostalCode__s, Address__CountryCode__s, Email__c, Phone__c
            FROM Shelter__c
            WHERE Address__City__s = :current.Address__City__s
        ];
    }
}
