public with sharing class TranslationAssignment_UpdatePrice extends TriggerClass {

    public override Boolean getIsToProcess(SObject sObjectOld, SObject sObjectNew) {
		return sObjectOld.get('Estimated_Count__c') != sObjectNew.get('Estimated_Count__c')
			|| sObjectOld.get('Task__c') != sObjectNew.get('Task__c')
			;
	}	

	public override void executeTrigger(SObject[] sObjectList) {
		
		Translation_Assignment__c[] taList = [SELECT Name
													, Estimated_Count__c
													, Task__c
													, Translator__c
													, Translator__r.Name
													, Translator__r.Char_Price__c
													, Translator__r.Word_Price__c
													, Translator__r.Minimum_Wage__c
													, Translation__c
													, Translation__r.Estimated_Units__c
													, Translation__r.Estimated_Count__c
													, Translation__r.Field__c
													, Translation__r.Source_Language__c
													, Translation__r.Target_Language__c
												FROM Translation_Assignment__c
												WHERE Id IN :sObjectList];

		Set<Id> traIdSet = new Set<Id>{};
		for (Translation_Assignment__c ta : taList) {
			if (ta.Translator__c == null) continue;
			traIdSet.add(ta.Translator__c);
		}
		
		Map<Id, Translator__c> traMap = new Map<Id, Translator__c>([SELECT Name
																, Char_Price__c
																, Word_Price__c
																, Minimum_Wage__c
																, (SELECT Base_Price__c
																		, Char_Price__c
																		, Field__c
																		, From__c
																		, To__c
																		, Word_Price__c
																		, Proofreading_Multiplier__c
																	FROM Language_Pairs__r)
															FROM Translator__c
															WHERE Id IN :traIdSet]);




		for (Translation_Assignment__c ta : taList) {
			ta = TranslationAssignmentService.calculatePrice(ta, traMap.get(ta.Translator__c));
		}

		update taList;
	}
}