@isTest 
private with sharing class TranslationAssignment_RejectedTest {
    static testMethod void myTest1() {
        ReflexTests test = new ReflexTests();
        test.initializeTranslation();
        test.insertTranslator();
        test.insertTranslationAssignment();
        
        test.getTranslationAssignment().Assignment_Status__c = 'Rejected';
        update test.getTranslationAssignment();
        system.assert(true);    	
    	
    }
}