trigger Translation_Gen on Translation__c (before insert,
										after insert,
										before update,
										after update,
										before delete,
										after delete) {
	new TriggerHandler(Translation__c.SObjectType).manage();
}