public class AdoptionUtils {
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