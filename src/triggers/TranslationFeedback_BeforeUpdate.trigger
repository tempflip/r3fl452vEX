trigger TranslationFeedback_BeforeUpdate on Translation_Feedback__c (before update) {
	new TranslationFeedback_RateTranslator(trigger.old, trigger.new).execute();
}