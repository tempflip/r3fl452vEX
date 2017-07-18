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

		// the language pair pricing
		Language_Pair__c lpSelected;
		Boolean withField = false;
		for (Language_Pair__c lp : tra.Language_Pairs__r) {
			if (ta.Translation__r.Source_Language__c == lp.From__c && ta.Translation__r.Target_Language__c == lp.To__c) {
				
				if (lp.Field__c == null && withField == false) {
					lpSelected = lp;
				}
				
				if (lp.Field__c != null && lp.Field__c == ta.Translation__r.Field__c) {
					lpSelected = lp;
					withField = true;
				}
			}

		}

		if (lpSelected != null) {
			if (!isWords && lpSelected.Char_Price__c != null) {
				unitPrice = lpSelected.Char_Price__c;
			} else if(isWords && lpSelected.Word_Price__c != null) {
				unitPrice = lpSelected.Word_Price__c;
			}
			ta.Language_Pair__c = lpSelected.Id;
		}

		ta.Translator_Price__c = (ta.Estimated_Count__c != null ? ta.Estimated_Count__c : 0) 
								* unitPrice;
		return ta;
	}
}