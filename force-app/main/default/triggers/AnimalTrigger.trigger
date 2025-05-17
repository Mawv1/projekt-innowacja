trigger AnimalTrigger on Animal__c (after insert, after update, after delete, after undelete) {
    
    Set<Id> shelterIds = new Set<Id>();

    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (Animal__c animal : Trigger.new) {
            if (animal.Shelter__c != null) {
                shelterIds.add(animal.Shelter__c);
            }
        }
    }

    if (Trigger.isUpdate || Trigger.isDelete) {
        for (Animal__c animal : Trigger.old) {
            if (animal.Shelter__c != null) {
                shelterIds.add(animal.Shelter__c);
            }
        }
    }

    AnimalTriggerHandler.updateUnadoptedAnimalCounts(shelterIds);
}