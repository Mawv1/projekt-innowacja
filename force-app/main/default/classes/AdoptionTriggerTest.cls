@IsTest
public class AdoptionTriggerTest {

    private static Account createTestAccount() {
        Account acc = new Account(
            FirstName = 'Test',
            LastName = 'account',
            PersonEmail = 'test@wp.pl',
            Phone = '123123123'
        );
        insert acc;
        return acc;
    }

    private static Animal__c createTestAnimal() {
        Shelter__c shelter = new Shelter__c(
            Name = 'Test Shelter',
            Location__Latitude__s = 52.2297,
            Location__Longitude__s = 21.0122
        );
        insert shelter;

        Animal__c animal = new Animal__c(Name = 'Test Animal', Shelter__c = shelter.Id);
        insert animal;

        return animal;
    }

    private static List<Adoption__c> generateAdoptions(Integer realCount, Integer virtualCount) {
        Account account = createTestAccount();
        Animal__c animal = createTestAnimal();

        Map<String, Id> recordTypeMap = AdoptionUtils.getAdoptionRecordTypes();
        List<Adoption__c> adoptions = new List<Adoption__c>();

        for (Integer i = 0; i < realCount + virtualCount; i++) {
            adoptions.add(new Adoption__c(
                Name = 'Real Adoption ' + i,
                Adopter__c = account.Id,
                Animal__c = animal.Id,
                Adoption_type__c = i < realCount ? 'Real' : 'Virtual',
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

    @isTest
    static void testSendStatusChangeEmails() {
        Shelter__c shelter = new Shelter__c(Name = 'Testowe Schronisko');
        insert shelter;

        Id personAccountRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account adopter = new Account(
            RecordTypeId = personAccountRtId,
            FirstName = 'John',
            LastName = 'Doe',
            PersonEmail = 'juszczykkrystian2003@gmail.com'
        );
        insert adopter;

        Animal__c animal = new Animal__c(
            Name = 'Rex',
            Shelter__c = shelter.Id
        );
        insert animal;

        Adoption__c adoption = new Adoption__c(
            Adopter__c = adopter.Id,
            Animal__c = animal.Id,
            Status__c = 'In progress'
        );
        insert adoption;

        // Update of the adoption record to trigger the email sending
        adoption.Status__c = 'Approved';
        update adoption;
    
        // Verify that the email was sent
        Integer results = Limits.getEmailInvocations();
        System.assertNotEquals(0, results, 'E-mail powinien zostać wysłany.');
    }
}