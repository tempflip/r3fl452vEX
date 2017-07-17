trigger TranslationAssignment_Gen on Translation_Assignment__c (before insert,
										after insert,
										before update,
										after update,
										before delete,
										after delete) {
	new TriggerHandler(Translation_Assignment__c.SObjectType).manage();
}