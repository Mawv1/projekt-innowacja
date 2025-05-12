trigger AdoptionTrigger on Adoption__c (before insert, before delete) {
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            AdoptionTriggerHandler.changeFoodPoints(Trigger.new, AdoptionTriggerHandler.INCREASE);
        }
        
        when BEFORE_DELETE {
            AdoptionTriggerHandler.changeFoodPoints(Trigger.old, AdoptionTriggerHandler.DECREASE);
        }
    }
}