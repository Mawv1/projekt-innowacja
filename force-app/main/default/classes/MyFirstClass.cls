public with sharing class MyFirstClass {
    public MyFirstClass() {
        Account acc = [SELECT Id FROM Account];
        System.debug('varName >>' );
    }
}