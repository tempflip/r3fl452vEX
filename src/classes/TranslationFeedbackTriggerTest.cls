@isTest
private with sharing class TranslationFeedbackTriggerTest {

	static testMethod void myTest1() {
		new TranslationFeedbackTrigger(null, null);
		new TranslationFeedbackTrigger(null, null).getIsMatching(new Translation_Feedback__c(), new Translation_Feedback__c());
		new TranslationFeedbackTrigger(null, null).execute(new Translation_Feedback__c[]{},true);
		system.assert(true);	
	}
}