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

    private static Adoption__c createValidAdoptionRecord(Integer amount) {
        Account adopterAcct = new Account(Name='Test Adopter Co.');
        insert adopterAcct;
        
        Shelter__c shelter = new Shelter__c(Name='Main Shelter');
        insert shelter;
        
        Animal__c animal = new Animal__c(
            Name       = 'Test Animal',
            Shelter__c = shelter.Id
        );
        insert animal;
        
        String statusVal = getAnyValidStatusValue();
        System.assertNotEquals(null, statusVal, 'Brak aktywnych wartości Status__c');

        Adoption__c rec = new Adoption__c(
            Name       = 'Test Adoption',
            Adopter__c = adopterAcct.Id,
            Animal__c  = animal.Id,
            Status__c  = statusVal,
            Amount__c  = amount
        );
        return rec;
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