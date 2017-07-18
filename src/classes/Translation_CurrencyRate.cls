public with sharing class Translation_CurrencyRate extends TriggerClass {

	public static Boolean disableTrigger = false;

    public override Boolean getIsToProcess(SObject sObjectOld, SObject sObjectNew) {
		if (disableTrigger == true) return false;

		return sObjectOld.get('Estimated_Price__c') != sObjectNew.get('Estimated_Price__c')
		//|| sObjectOld.get('Estimated_Price_EUR__c') != sObjectNew.get('Estimated_Price_EUR__c')
		;
	}	

	public override void executeTrigger(SObject[] sObjectList) {

		Translation_CurrencyRate.disableTrigger = true; // run only once

		Fixer_Rates__c rates = Fixer_Rates__c.getOrgDefaults();
		if (rates == null) return;
		if (rates.EUR_to_HUF__c == null) return;

		for (Translation__c tra : (Translation__c[]) sObjectList) {
			// HUF updated
			if (tra.Estimated_Price__c != null && 
				(
					Trigger.isInsert
					||
					tra.Estimated_Price__c != Trigger.oldMap.get(Tra.Id).get('Estimated_Price__c')
				)) 
			{
				tra.Estimated_Price_EUR__c = tra.Estimated_Price__c / rates.EUR_to_HUF__c;
				tra.Current_EUR_To_HUF__c = rates.EUR_to_HUF__c;
			} 
			// EUR updated
			else if (tra.Estimated_Price_EUR__c != null &&
				(
					Trigger.isInsert
					||
					tra.Estimated_Price_EUR__c != Trigger.oldMap.get(Tra.Id).get('Estimated_Price_EUR__c')

				)) 
			{
				tra.Estimated_Price__c = tra.Estimated_Price_EUR__c * rates.EUR_to_HUF__c;
				tra.Current_EUR_To_HUF__c = rates.EUR_to_HUF__c;
			}
		}

	}
}