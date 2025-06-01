@isTest
private class MissingAnimalServiceTest {

    @isTest
    static void testCreateMissingAnimal() {
        System.Test.setMock(HttpCalloutMock.class, new MissingAnimalMock());
        AuthService.setMockAccessToken('mock-token');

        MissingAnimalService.MissingAnimalWrapper wrapper = new MissingAnimalService.MissingAnimalWrapper();
        wrapper.report = new MissingAnimalService.ReportWrapper();
        wrapper.report.address = 'Warszawa, ul. Testowa 1';
        wrapper.report.disappearancePlaceLatitude = 52.2297;
        wrapper.report.disappearancePlaceLongitude = 21.0122;
        wrapper.report.disappearanceDate = '2024-10-10';
        wrapper.report.description = 'Zaginął pies rasy testowej';

        wrapper.animal = new MissingAnimalService.AnimalCreateWrapper();
        wrapper.animal.name = 'Reksio';
        wrapper.animal.imageUrl = 'https://example.com/image.jpg';
        wrapper.animal.breed = 'Mieszaniec';
        wrapper.animal.age = 5;
        wrapper.animal.uniqueFeatures = 'Biała łata na uchu';
        wrapper.animal.size = 'Średni';

        System.Test.startTest();
        MissingAnimalService.createMissingAnimal(wrapper);
        System.Test.stopTest();

        System.assert(true, 'Powinno przejść bez wyjątku');
    }

    @isTest
    static void testUpdateAnimalFoundStatus() {
        System.Test.setMock(HttpCalloutMock.class, new MissingAnimalMock());
        AuthService.setMockAccessToken('mock-token');

        System.Test.startTest();
        MissingAnimalService.updateAnimalFoundStatus('ANO-032', true);
        System.Test.stopTest();

        System.assert(true, 'Powinno przejść bez wyjątku');
    }
}
