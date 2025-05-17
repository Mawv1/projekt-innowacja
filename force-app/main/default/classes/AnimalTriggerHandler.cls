public with sharing class AnimalTriggerHandler {
    public static void updateUnadoptedAnimalCounts(Set<Id> shelterIds) {
        if (shelterIds.isEmpty()) return;

        Map<Id, Integer> countMap = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT Shelter__c shelterId, COUNT(Id) unadoptedCount
            FROM Animal__c
            WHERE Shelter__c IN :shelterIds AND (Status__c = 'Available' OR Status__c = null)
            GROUP BY Shelter__c
        ]) {
            countMap.put((Id) ar.get('shelterId'), (Integer) ar.get('unadoptedCount'));
        }

        List<Shelter__c> sheltersToUpdate = new List<Shelter__c>();
        for (Id shelterId : shelterIds) {
            Integer count = countMap.get(shelterId);
            Shelter__c shelter = new Shelter__c(
                Id = shelterId,
                Unadopted_Animal_Count__c = (count != null ? count : 0)
            );
            sheltersToUpdate.add(shelter);
        }

        if (!sheltersToUpdate.isEmpty()) {
            update sheltersToUpdate;
        }
    }
}