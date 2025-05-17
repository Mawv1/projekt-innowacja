trigger AdoptionTrigger on Adoption__c (before insert ,after insert, before update, after update, before delete) {
    switch on Trigger.operationType {
        when BEFORE_UPDATE {
            AdoptionTriggerHandler.changeAdoptionType(Trigger.new);
        }
        
        when BEFORE_INSERT {
            AdoptionTriggerHandler.changeAdoptionType(Trigger.new);
        }
        
        when AFTER_UPDATE {
            AdoptionTriggerHandler.changeFoodPoints(Trigger.new, Trigger.oldMap, Trigger.operationType);
            AdoptionTriggerHandler.sendStatusChangeEmails(Trigger.new, Trigger.oldMap);
        }

        when AFTER_INSERT {
            AdoptionTriggerHandler.changeFoodPoints(Trigger.new, Trigger.oldMap, Trigger.operationType);
        }

        when BEFORE_DELETE {
            AdoptionTriggerHandler.changeFoodPoints(Trigger.old, Trigger.oldMap, Trigger.operationType);
        }
    }
}
