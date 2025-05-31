@isTest
private class MissingAnimalServiceTest {

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