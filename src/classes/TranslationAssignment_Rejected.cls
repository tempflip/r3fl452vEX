public class TranslationAssignment_Rejected extends TranslationAssignmentTrigger {
    
    public TranslationAssignment_Rejected(Translation_Assignment__c[] sobjectOldList, Translation_Assignment__c[] sobjectNewList) {
        super(sobjectOldList, sobjectNewList);
    }    
    
    public override Boolean getIsMatching(Translation_Assignment__c sobjectOld, Translation_Assignment__c sobjectNew) {
        return sobjectOld.Assignment_Status__c != ReflexSettings.ASSIGNMENT_STATUS_REJECTED &&  sobjectNew.Assignment_Status__c == ReflexSettings.ASSIGNMENT_STATUS_REJECTED;
    }    

    public override void execute(Translation_Assignment__c[] sobjectList, Boolean doUpdate) {
        Map<Id, User> userMap = new Map<Id, User>([SELECT Name
                                                    , Email 
                                                    FROM User]);
        
        Map <Id, Translation__c> translationMap = new Map <Id, Translation__c> ([SELECT Name 
                                                                                ,OwnerId
                                                                                FROM Translation__c]);  
                                                                                
        Map <Id, Translator__c>  translatorMap = new Map <Id, Translator__c>([SELECT Name
                                                                                FROM Translator__c]);
                                                                                                                                                                                                             
        Messaging.SingleEmailMessage[] mailList = new Messaging.SingleEmailMessage[]{};                                                                                 
        for (Translation_Assignment__c tra : sobjectList) {
            Set<String> toAddresses = New Set<String>();
            Translation__c translation = translationMap.get(tra.Translation__c);
            Id userId = translation.OwnerId;
            // the recepient
            toAddresses.add(userMap.get(userId).Email);
            
            Map<String, String> taskMap = new Map<String, String>{
            	'Translating' => 'fordítást',
            	'Proofreading' => 'lektorálást',
            	'Editing' => 'korrektúrát',
            	'Supervising' => 'editálást'
            };
             
            // the body   
            Map<String, String> fieldMap = new Map <String, String> {
            	'user_name' => userMap.get(userId).Name,
            	'translation_name' => translationMap.get(tra.Translation__c).Name,
            	'task' => taskMap.get(tra.Task__c),
            	'rejection_reason' => tra.Rejection_Reason__c == null ? '' : tra.Rejection_Reason__c,
            	'translator_name' => translatorMap.get(tra.Translator__c).Name
            };
            String emailBody = replacePlaceHolders(ReflexSettings.EMAIL_TEMPLATE_TASK_REJECTION, fieldMap);

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setUseSignature(false); 
            mail.setToAddresses(new List<String>(toAddresses));
            mail.setSubject('REFLEX: Lemondott munka -- ' + translation.Name);
            mail.setHtmlBody(emailBody);
            mailList.add(mail);    
        }
        
        try {
            Messaging.sendEmail(mailList);
        } catch (system.exception e) {}
       
    }
    
    public String replacePlaceHolders(String s, Map<String, String> fieldMap) {
        for (String key : fieldMap.keySet()) {
            s = s.replace('{{' + key + '}}', fieldMap.get(key));
        }
        return s;
    }    
}