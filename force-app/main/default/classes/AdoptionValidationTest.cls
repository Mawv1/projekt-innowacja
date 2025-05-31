@IsTest
private class AdoptionValidationTest {

    private static String getAnyValidStatusValue() {
        Schema.DescribeFieldResult dr = Adoption__c.Status__c.getDescribe();
        for (Schema.PicklistEntry pe : dr.getPicklistValues()) {
            if (pe.isActive()) {
                return pe.getValue();   
            }
        }
        return null;
    }

    private static Adoption__c createValidAdoptionRecord(Decimal amount) {
        // Tworzymy konto Adopter
        Account adopter = new Account(Name = 'Test Adopter');
        insert adopter;

        Shelter__c shelter = new Shelter__c(
            // Name = 'Test Shelter',
            // Street__c = '123 Main St',
            // Adress__City__s = 'Test City',
            // Adress__State__s = 'Test State',
            // Adress__PostalCode__s = '12-345',
            // Adress__Country__s = 'Poland',
            // Email__c = 'test@shelter.com',
            // Phone__c = '123456789',
            // Capacity__c = 100
        );
        insert shelter;

        // Tworzymy zwierzę przypisane do schroniska
        Animal__c animal = new Animal__c(
            Name = 'Test Animal',
            Sex__c = 'Male',
            Shelter__c = shelter.Id
        );
        insert animal;

        // Pobieramy aktywną wartość statusu
        String statusVal = getAnyValidStatusValue();
        System.assertNotEquals(null, statusVal, 'Brak aktywnych wartości Status__c');

        // Tworzymy rekord adopcji
        Adoption__c adoption = new Adoption__c(
            Name = 'Test Adoption',
            Adopter__c = adopter.Id,
            Animal__c = animal.Id,
            Status__c = statusVal,
            Amount__c = amount
        );

        return adoption;
    }

    @IsTest static void testAmountTooLow() {
        Adoption__c rec = createValidAdoptionRecord(5);
        try {
            insert rec;
            System.assert(false, 'Oczekiwano wyjątku walidacji Amount < 10');
        } catch (DmlException ex) {
            System.assert(
                ex.getMessage().contains('Amount must be at least 10'),
                'Brak komunikatu walidacji lub inny komunikat: ' + ex.getMessage()
            );
        }
    }

    @IsTest static void testAmountOk() {
        Adoption__c rec = createValidAdoptionRecord(10);
        insert rec;  // powinno przejść

        Adoption__c loaded = [
            SELECT Amount__c 
            FROM Adoption__c 
            WHERE Id = :rec.Id
        ];
        System.assertEquals(10, loaded.Amount__c, 'Amount powinien zostać zapisany jako 10');
    }
}