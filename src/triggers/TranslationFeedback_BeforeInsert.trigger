trigger TranslationFeedback_BeforeInsert on Translation_Feedback__c (before insert) {
	new TranslationFeedback_RateTranslator(trigger.old, trigger.new).execute();
}