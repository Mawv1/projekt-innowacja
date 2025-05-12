@IsTest
public class AdoptionTriggerTest {

    @IsTest
    static void testChangeFoodPoints() {
        Shelter__c shelter = new Shelter__c(Name = 'Test Shelter1');
        insert shelter;

        Animal__c animal = new Animal__c(Name = 'Test Animal1', Shelter__c = shelter.Id);
        insert animal;

        Person__c person = new Person__c(Name = 'Test Person1');
        insert person;
        
        Id personId = person.Id;

        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Account' AND Name = 'Person Account' 
            LIMIT 1
        ];

        Account acc = new Account(
            RecordTypeId = rt.Id,
            FirstName = 'Test',
            LastName = 'User',
            Person__c = person.Id
        );
        insert acc;

        person.Person_Account__c = acc.Id;
        update person;

        Map<String, Id> rtList = AdoptionTriggerHandler.getAdoptionRecordTypes();

        Integer realCount = 4;
        Integer virtualCount = 6;
        Integer expectedFoodPoints = (realCount * 20) + (virtualCount * 10);

        List<Adoption__c> adoptionList = new List<Adoption__c>();

        for (Integer i = 0; i < realCount; ++i) {
            adoptionList.add(new Adoption__c(
                Name = 'Test Real ' + i,
                Adopter__c = acc.Id,
                Animal__c = animal.Id,
                Person__c = acc.Person__c,
                RecordTypeId = rtList.get('Real')
            ));
        }

        for (Integer i = 0; i < virtualCount; ++i) {
            adoptionList.add(new Adoption__c(
                Name = 'Test Virtual ' + i,
                Adopter__c = acc.Id,
                Animal__c = animal.Id,
                Person__c = acc.Person__c,
                RecordTypeId = rtList.get('Virtual')
            ));
        }

        Test.startTest();
        insert adoptionList;
        Test.stopTest();

        person = [SELECT Food_Points__c FROM Person__c WHERE Id = :personId];
        System.assertEquals(expectedFoodPoints, person.Food_Points__c, 'Food points after insert are incorrect');

        Test.startTest();
        delete adoptionList;
        Test.stopTest();

        person = [SELECT Food_Points__c FROM Person__c WHERE Id = :personId];
        System.assertEquals(0, person.Food_Points__c, 'Food points after delete should be 0');
    }
}