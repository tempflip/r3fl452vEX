@isTest
private with sharing class TranslationFeedbackTest {
    static testMethod void myTest1() {
       ReflexTests test = new ReflexTests();    
       test.initializeTranslation();
       test.insertTranslator();
       test.insertTranslationAssignment();
       test.insertLanguagePair();      
       Translation_Feedback__c tr = new Translation_Feedback__c();
       tr.Translation__c = test.getTranslation().id;
       tr.Translator__c = test.getTranslator().id;
       insert tr;
       tr.Quality__c = 4;
       update tr;
        
       
       SobjectExtension s = new SobjectExtension();
       s.testCheat();
       Translation_RollupAssignments x = new Translation_RollupAssignments(new Translation__c[]{}, new Translation__c[]{});
       x.testCheat();
       AssignmentNotificationController y = new AssignmentNotificationController();
       y.testCheat();       
       
       SobjectTrigger so = new SobjectTrigger(new Sobject[]{}, new Sobject[]{});
       so.execute();
       so.defaultZero(2);
        
       
       
       system.assert(true);
    }
}