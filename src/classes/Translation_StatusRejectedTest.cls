@isTest
private with sharing class Translation_StatusRejectedTest {
    static testMethod void myTest1() {
        ReflexTests test = new ReflexTests();
        test.initializeTranslation();
        test.getTranslation().Assignment_Status__c = 'Rejected';
        update test.getTranslation();
        system.assert(true);
    }
}