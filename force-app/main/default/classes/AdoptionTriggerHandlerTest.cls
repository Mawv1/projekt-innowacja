@isTest
private class AdoptionTriggerHandlerTest {
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