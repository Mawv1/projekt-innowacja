public with sharing class AnimalTriggerHandler {
    public static final String STATUS_ADOPTED = 'Adopted';


    public static void updateUnadoptedAnimalCounts(List<Animal__c> newAnimalList, List<Animal__c> oldAnimalList, System.TriggerOperation operationType) {
        Set<Id> shelterIds = new Set<Id>();

        if (operationType == System.TriggerOperation.AFTER_INSERT || operationType == System.TriggerOperation.AFTER_UPDATE || operationType == System.TriggerOperation.AFTER_UNDELETE) {
            for (Animal__c animal : newAnimalList) {
                if (animal.Shelter__c != null) {
                    shelterIds.add(animal.Shelter__c);
                }
            }
        }

        if (operationType == System.TriggerOperation.AFTER_UPDATE || operationType == System.TriggerOperation.AFTER_DELETE) {
            for (Animal__c animal : oldAnimalList) {
                if (animal.Shelter__c != null) {
                    shelterIds.add(animal.Shelter__c);
                }
            }
        }

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

    public static void updateAdoptedAnimalCounts(List<Animal__c> animalList, Map<Id, Animal__c> oldMap, System.TriggerOperation operationType) {
        Map<Id, Integer> shelterAnimalCountMap = new Map<Id, Integer>();

        for (Animal__c animal : animalList) {
            Integer counter = 0;

            if ((operationType == System.TriggerOperation.AFTER_INSERT || operationType == System.TriggerOperation.AFTER_UPDATE) 
                && animal.Status__c == STATUS_ADOPTED) {
                counter++;
            } else if ((operationType == System.TriggerOperation.BEFORE_DELETE && animal.Status__c == STATUS_ADOPTED)
                || (operationType == System.TriggerOperation.AFTER_UPDATE && animal.Status__c != oldMap.get(animal.Id).Status__c && animal.Status__c == STATUS_ADOPTED)) {
                counter--;
            } else {
                continue;
            }

            if (shelterAnimalCountMap.containsKey(animal.Shelter__c)) {
                counter += shelterAnimalCountMap.get(animal.Shelter__c);
            }

            shelterAnimalCountMap.put(animal.Shelter__c, counter);
        }

        List<Shelter__c> shelterList = [SELECT Id, Adopted_Animal_Count__c FROM Shelter__c WHERE Id IN :shelterAnimalCountMap.keySet()];

        for (Shelter__c shelter : shelterList) {
            shelter.Adopted_Animal_Count__c = shelterAnimalCountMap.get(shelter.Id);
        }
            

        update shelterList;
    }
}