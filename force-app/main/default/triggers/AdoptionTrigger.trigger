trigger AdoptionTrigger on Adoption__c (after insert, after update, before delete) {
    AdoptionTriggerHandler.changeFoodPoints(Trigger.new, Trigger.operationType);
}
