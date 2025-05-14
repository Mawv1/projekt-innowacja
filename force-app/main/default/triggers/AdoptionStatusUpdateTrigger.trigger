trigger AdoptionStatusUpdateTrigger on Adoption__c (after update) {
    AdoptionTriggerHandler.sendStatusChangeEmails(Trigger.new, Trigger.oldMap);
}