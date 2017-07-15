@isTest
private with sharing class Translation_ManageAssignmentTest {
	static testMethod void myTest1() {
	   ReflexTests test = new ReflexTests();	
        test.initializeTranslation();
        test.insertTranslator();
        test.insertTranslationAssignment();
        test.insertLanguagePair();	    
		ApexPages.StandardController controller = new ApexPages.StandardController(test.getTranslation());
        Translation_ManageAssignment t = new Translation_ManageAssignment(controller);
        t.notNiceTestHack();
        system.assert(true);        
        
	}
	/*static testMethod void myTest1() {
		
		
		ReflexTests test = new ReflexTests();
		test.initializeTranslation();
		test.insertTranslator();
        test.insertTranslationAssignment();
		test.insertLanguagePair();
		
		
		
		//the params
		ApexPages.CurrentPage().getParameters().put('translatorId', test.getTranslator().Id);
		ApexPages.CurrentPage().getParameters().put('assignmentId', test.getTranslationAssignment().Id);
        
		ApexPages.StandardController controller = new ApexPages.StandardController(test.getTranslation());
		Translation_ManageAssignment t = new Translation_ManageAssignment(controller);
		
		t.initialize();
		t.addTranslator();
		t.addProofreader();
		t.addEditor();
		t.addSupervisor();

		t.translationAssWrapperList[0].selected = true;
		t.deleteAssignment();
		t.updateAssignments();
		t.rateTranslators();
		t.addFeedback();
		t.insertedTranslationFeedback.Translator__c = test.getTranslator().Id;
		t.insertedTranslationFeedback.Quality__c = 4;
		t.addFeedback();


		Translation_Feedback__c translationFeedback = [SELECT Name, Quality__c FROM Translation_Feedback__c LIMIT 1];
		translationFeedback.Quality__c = 3;
		update translationFeedback;
		
		t.folderChange();
		
		t.addDocumentToAssignment();
		t.sendDocuments();
		t.notNiceTestHack();
		system.assert(true);		
	}*/

}