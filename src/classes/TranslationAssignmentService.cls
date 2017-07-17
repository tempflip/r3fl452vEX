public with sharing class TranslationAssignmentService {


	public static Translation_Assignment__c calculatePrice(Translation_Assignment__c ta, Translator__c tra) {

		// words or chars ?
		Boolean isWords = false;
		if (ta.Translation__r.Estimated_Units__c == ReflexSettings.TRANSLATION_ESTIMATED_UNITS_WORDS) {
			isWords = true;
		}

		// the unit price on translator level
		Decimal unitPrice = 0;
		if (tra != null) {
			if (!isWords && tra.Char_Price__c != null) {
				unitPrice = tra.Char_Price__c;
			} else if (isWords && tra.Word_Price__c != null) {
				unitPrice = tra.Word_Price__c;
			}
		}

		ta.Translator_Price__c = (ta.Estimated_Count__c != null ? ta.Estimated_Count__c : 0) 
								* unitPrice;
		return ta;
	}
}
