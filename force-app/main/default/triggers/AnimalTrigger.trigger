trigger AnimalTrigger on Animal__c (after insert, after update, after delete, after undelete, before delete) {
    
        switch on Trigger.operationType {
            when BEFORE_DELETE {
                AnimalTriggerHandler.updateAdoptedAnimalCounts(Trigger.old, Trigger.oldMap, Trigger.operationType);
            }
            when AFTER_DELETE {
                AnimalTriggerHandler.updateUnadoptedAnimalCounts(Trigger.new, Trigger.old, Trigger.operationType);
            }
            when AFTER_UNDELETE {
                AnimalTriggerHandler.updateUnadoptedAnimalCounts(Trigger.new, Trigger.old, Trigger.operationType);
            }
            when else {
                AnimalTriggerHandler.updateAdoptedAnimalCounts(Trigger.new, Trigger.oldMap, Trigger.operationType);
                AnimalTriggerHandler.updateUnadoptedAnimalCounts(Trigger.new, Trigger.old, Trigger.operationType);
            }
        }
    
}