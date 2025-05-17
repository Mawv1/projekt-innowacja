public with sharing class ShelterHoursController {
    @AuraEnabled(cacheable=true)
    public static List<Shelter_Opening_Hour__c> getOpeningHours(Id shelterId) {
        return [
            SELECT Id, Day__c, Open__c, Close__c, Closed__c
            FROM Shelter_Opening_Hour__c
            WHERE Shelter__c = :shelterId
            ORDER BY Day__c
        ];
    }
}