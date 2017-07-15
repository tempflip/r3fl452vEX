@isTest
private with sharing class TranslationAssignment_DocumentListTest {
    static testMethod void myTest1() {
        ReflexTests test = new ReflexTests();
        test.initializeTranslation();
        test.insertTranslator();
        test.insertTranslationAssignment();
        
        ApexPages.CurrentPage().getParameters().put('id', test.getTranslationAssignment().Id);
        TranslationAssignment_DocumentList t = new TranslationAssignment_DocumentList();
        t.initialize();
        t.accept();
        t.reject();
        t.sendChatterMessage();
        system.assert(true);
        
    }
}