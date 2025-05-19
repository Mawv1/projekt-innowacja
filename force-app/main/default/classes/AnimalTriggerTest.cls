@IsTest
public class AnimalTriggerTest {
    private static Shelter__c createShelter() {
        Shelter__c shelter = new Shelter__c(
            Name = 'Test Shelter'
        );
        insert shelter;

        return shelter;
    } 

    private static List<Animal__c> createAnimals(Shelter__c shelter, Integer countAdopted, Integer countAll) {
        List<Animal__c> animals = new List<Animal__c>();

        for (Integer i = 0; i < countAll; i++) {
            Animal__c animal = new Animal__c(
                    Name = 'Test animal ' + i,
                    Shelter__c = shelter.Id
                );
            if (i < countAdopted) {
                animal.Status__c = AnimalTriggerHandler.ANIMAL_STATUS_ADOPTED;
            }

            animals.add(animal);
        }
        insert animals;

        return animals;
    }

    @IsTest
    static void testAdoptedAnimalsCount() {
        Shelter__c shelter = createShelter();
        Integer adoptedCount = 4;
        Integer allCount = 9;
        
        List<Animal__c> animals = createAnimals(shelter, adoptedCount, allCount);

        shelter = [SELECT Id, Adopted_Animal_Count__c FROM Shelter__c WHERE Id = :shelter.Id];

        System.assertEquals(adoptedCount, shelter.Adopted_Animal_Count__c, 'Food points after insert are incorrect');
    }
}