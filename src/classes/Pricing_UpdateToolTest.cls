@isTest
private with sharing class Pricing_UpdateToolTest {
    static testMethod void myTest1() {
        ReflexTests test = new ReflexTests();
        test.initializeTranslation();
        test.insertTranslator();
        test.insertTranslationAssignment();
        test.insertLanguage();
        test.getLanguage().Language_Code__c = 'HU';
        update test.getLanguage();
        test.insertLanguagePair();
        
        Pricing_UpdateTool t = new Pricing_UpdateTool();
        t.initialize();
        t.lList1 = 'EN';
        t.lList2 = 'HU';
        t.sourceChar = '2';
        t.targetChar = '2';
        t.sourceWord = '2';
        t.targetWord = '2';        
        t.prMult = '2'; 
        t.urMult = '2'; 
        t.exMult = '2';      
        
        t.generatePricing();
        t.upsertPricing();
        
        system.assert(true);
    }
}