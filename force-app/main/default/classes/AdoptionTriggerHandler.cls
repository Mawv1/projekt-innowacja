public class AdoptionTriggerHandler {
    public static final String DECREASE = 'DECREASE';
    public static final String INCREASE = 'INCREASE';
    public static final Integer REAL_ADOPTION_POINTS = 20;
    public static final Integer VIRTUAL_ADOPTION_POINTS = 10;
    public static final Integer FOOD_GIFT_GOAL = 30;
    
    
    public static void changeFoodPoints(List<Adoption__c> adoptionList, String changeType) {
        Map<String, Id> rtMap = getAdoptionRecordTypes();
        Map<Id, Integer> fpMap = new Map<Id, Integer>();
        
         for (Adoption__c adoption : adoptionList) {
            Integer counter = 0;
            
            System.debug(changeType);
            if (adoption.RecordTypeId == rtMap.get('Real')) {
                System.debug('Real adoption');
                counter += changeType == INCREASE ? REAL_ADOPTION_POINTS : -REAL_ADOPTION_POINTS;
            } else {
                System.debug('Virtual adoption');
                counter += changeType == INCREASE ? VIRTUAL_ADOPTION_POINTS : -VIRTUAL_ADOPTION_POINTS;
            }             
             if (fpMap.containsKey(adoption.Person__c))
                 counter += fpMap.get(adoption.Person__c);
            fpMap.put(adoption.Person__c,  counter);
            
         }
        
        List<Person__c> personList = [SELECT Food_Points__c, Name, Food_Gift__c, Id FROM Person__c WHERE Id in :fpMap.keySet()];
        
        for (Person__c person : personList) {
            System.debug('Person ' + person.Name + ' gain ' + fpMap.get(person.Id) + ' food points');
            person.Food_Points__c += fpMap.get(person.Id);
            
            if (person.Food_Points__c >= FOOD_GIFT_GOAL) 
                person.Food_Gift__c = True;
        }    
     
        if (!personList.isEmpty()) {
            System.debug('updating');
            
            update personList;
        } else {
            System.debug('List is empty');
        }
    }
    
    public static Map<String, Id> getAdoptionRecordTypes() {
        List<RecordType> recordTypeList = [
       		SELECT Id, DeveloperName
        	FROM RecordType
        	WHERE SObjectType = 'Adoption__c'
        	AND DeveloperName IN ('Real', 'Virtual')
    	];
        
        Map<String, Id> recordTypeMap = new Map<String, Id>();
    	for (RecordType rt : recordTypeList) {
        	recordTypeMap.put(rt.DeveloperName, rt.Id);
    	}
        
        return recordTypeMap;
    }
}