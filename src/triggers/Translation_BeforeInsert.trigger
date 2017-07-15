trigger Translation_BeforeInsert on Translation__c (before insert) {
	new Translation_EstimatePrice(trigger.old, trigger.new).execute();
	new Translation_AssignToBranch(null, trigger.new).execute();
}