public with sharing class TranslationFeedback_RateTranslator extends TranslationFeedbackTrigger{

    public TranslationFeedback_RateTranslator(Translation_Feedback__c[] sobjectOldList, Translation_Feedback__c[] sobjectNewList) {
        super(sobjectOldList, sobjectNewList);
    }    

    public override Boolean getIsMatching(Translation_Feedback__c sobjectOld, Translation_Feedback__c sobjectNew) {
    	return true;
    }

    public override void execute(Translation_Feedback__c[] sobjectList, Boolean doUpdate) {
    	
    	Map<Id, Translator__c> translatorMap = new Map<Id, Translator__c>([SELECT Name
    										    						FROM Translator__c
    										    						LIMIT 10000]);
    	Map<Id, Decimal> qualityRatingCount = new Map<Id, Decimal>();
		Map<Id, Decimal> qualityRatingScore = new Map<Id, Decimal>();

    	for (Translation_Feedback__c feedback : sobjectList) {
    		// if this is a general feedbeck, we are skipping it
    		if (feedback.Translator__c == null) { 
    			continue;
    		}
    		// the quality count
    		if (feedback.Quality__c != null) {
	    		if (qualityRatingCount.containsKey(feedback.Translator__c) == true) {
	    			qualityRatingCount.put(feedback.Translator__c, qualityRatingCount.get(feedback.Translator__c) + 1);
	    			qualityRatingScore.put(feedback.Translator__c, qualityRatingScore.get(feedback.Translator__c) + feedback.Quality__c);
	    		}
	    		else {
	    			qualityRatingCount.put(feedback.Translator__c, 1);
	    			qualityRatingScore.put(feedback.Translator__c, feedback.Quality__c);
	    		}
    		}
    	}

    	// calculating the score for each translator
    	for (Id id : qualityRatingCount.keySet() ) {
    		system.debug('COUNT ' + qualityRatingCount);
    		system.debug('SCORE ' + qualityRatingScore);
    		translatorMap.get(id).Quality_Rating__c = qualityRatingScore.get(id) / qualityRatingCount.get(id);
    	}

    	try {
    		update translatorMap.values();
    	} 
    	catch (system.exception e) { }
		
    }
}