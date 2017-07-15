trigger Translation_BeforeUpdate on Translation__c (before update) {
	new Translation_EstimatePrice(trigger.old, trigger.new).execute();
	new Translation_RollupAssignments(trigger.old, trigger.new).execute();
	new Translation_StatusRejected(trigger.old, trigger.new).execute();
}