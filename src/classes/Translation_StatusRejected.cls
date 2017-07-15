public class Translation_StatusRejected extends TranslationTrigger {
	
    public Translation_StatusRejected(Translation__c[] sobjectOldList, Translation__c[] sobjectNewList) {
        super(sobjectOldList, sobjectNewList);
    }    
    
    public override Boolean getIsMatching(Translation__c sobjectOld, Translation__c sobjectNew) {
        return sobjectOld.Assignment_Status__c != ReflexSettings.ASSIGNMENT_STATUS_REJECTED &&	sobjectNew.Assignment_Status__c == ReflexSettings.ASSIGNMENT_STATUS_REJECTED;
    }    

    public override void execute(Translation__c[] sobjectList, Boolean doUpdate) {
        Map <Id,Translation_Assignment__c> traMap = new Map <Id,Translation_Assignment__c>([SELECT Name
                                                                                        ,Translation__c
										                                                ,Translator__r.Email__c
										                                                ,Translator__r.Secondary_Email__c
										                                                FROM Translation_Assignment__c
	           							                                                WHERE Translation__c IN :sobjectList]);
	    
	    Messaging.SingleEmailMessage[] mailList = new Messaging.SingleEmailMessage[]{};      							                                                
        for (Translation__c translation : sobjectList) {
        	// getting all the emails for the assigned translators
        	Set<String> toAddresses = new Set<String>();
        	for (Translation_Assignment__c tra : traMap.values()) {
        	    if (tra.Translation__c == translation.Id) {
        	        if (tra.Translator__r.Email__c != null) {
        	        	toAddresses.add(tra.Translator__r.Email__c);
        	        }   
                    if (tra.Translator__r.Secondary_Email__c != null) {
                        toAddresses.add(tra.Translator__r.Secondary_Email__c);
                    }           	        
        	    }	
        	}
        	
	        
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        mail.setUseSignature(false); 
	        mail.setToAddresses(new List<String>(toAddresses));
	        mail.setSubject('REFLEX: Megszunt feladat --' + translation.Name);
	        mail.setHtmlBody('A kovetkezo feladat MEGSZUNT. ' + translation.Name);
	        mailList.add(mail);        	
        }
        
        system.debug('+++ MAILLIST ' + mailList);
        try {
            Messaging.sendEmail(mailList);
        } catch (system.exception e) {}
       
    }
}