@IsTest
public class AdoptionTriggerTest {

    private static Person__c createTestPerson() {
        Person__c person = new Person__c(Name = 'Test Person');
        insert person;
        return person;
    }

    private static Animal__c createTestAnimal() {
        Shelter__c shelter = new Shelter__c(Name = 'Test Shelter');
        insert shelter;

        Animal__c animal = new Animal__c(Name = 'Test Animal', Shelter__c = shelter.Id);
        insert animal;

        return animal;
    }

    private static List<Adoption__c> generateAdoptions(Integer realCount, Integer virtualCount) {
        Person__c person = createTestPerson();
        Animal__c animal = createTestAnimal();

        Map<String, Id> recordTypeMap = AdoptionUtils.getAdoptionRecordTypes();
        List<Adoption__c> adoptions = new List<Adoption__c>();

        for (Integer i = 0; i < realCount; i++) {
            adoptions.add(new Adoption__c(
                Name = 'Real Adoption ' + i,
                Adopter__c = person.Id,
                Animal__c = animal.Id,
                RecordTypeId = recordTypeMap.get('Real'),
                Status__c = 'Approved'
            ));
        }

        for (Integer i = realCount; i < realCount + virtualCount; i++) {
            adoptions.add(new Adoption__c(
                Name = 'Virtual Adoption ' + i,
                Adopter__c = person.Id,
                Animal__c = animal.Id,
                RecordTypeId = recordTypeMap.get('Virtual'),
                Status__c = 'Approved'
            ));
        }

        return adoptions;
    }

    @IsTest
    static void testAdoptionInsert() {
        Integer realCount = 2;
        Integer virtualCount = 3;
        Integer expectedPoints = (realCount * AdoptionTriggerHandler.REAL_ADOPTION_POINTS) +
                                 (virtualCount * AdoptionTriggerHandler.VIRTUAL_ADOPTION_POINTS);

        List<Adoption__c> adoptions = generateAdoptions(realCount, virtualCount);

        System.Test.startTest();
        insert adoptions;
        System.Test.stopTest();

        Account acc = [SELECT Food_Points__c FROM Account WHERE Id = :adoptions.get(0).Adopter__c];
        System.assertEquals(expectedPoints, acc.Food_Points__c, 'Food points after insert are incorrect');
    }

    @IsTest
    static void testAdoptionDelete() {
        Integer realCount = 2;
        Integer virtualCount = 3;
        Integer expectedPoints = (realCount * AdoptionTriggerHandler.REAL_ADOPTION_POINTS) +
                                 (virtualCount * AdoptionTriggerHandler.VIRTUAL_ADOPTION_POINTS);

        List<Adoption__c> adoptions = generateAdoptions(realCount, virtualCount);

        insert adoptions;

        Account acc = [SELECT Food_Points__c FROM Account WHERE Id = :adoptions.get(0).Adopter__c];
        System.assertEquals(expectedPoints, acc.Food_Points__c, 'Food points after insert are incorrect');
    
        System.Test.startTest();
        delete adoptions;
        System.Test.stopTest();

        acc = [SELECT Food_Points__c FROM Account WHERE Id = :adoptions.get(0).Adopter__c];
        System.assertEquals(0, acc.Food_Points__c, 'Food points after delete should be 0');
    }
}