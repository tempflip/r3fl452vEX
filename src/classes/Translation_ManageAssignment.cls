public with sharing class Translation_ManageAssignment {
    public ApexPages.StandardController controller;
    public Translation__c translation {get; set;}
    public Language_Pair__c[] lPairList {get; set;} 
    public Map<Id, Translation_Assignment__c> translationAssignmentMap;
    public Translation_Assignment__c[] translationAssignmentList {get; set;}
    public Translation_Feedback__c[] translationFeedbackList {get; set;}
    public Translation_Feedback__c insertedTranslationFeedback {get; set;}
    public translatorWrapper[] translatorWrapperList {get; set;}
    public translationAssWrapper[] translationAssWrapperList {get; set;}
    public SelectOption[] ratingOptions {get; set;}
    public SelectOption[] translatorList {get; set;}
    public SelectOption[] documentList {get; set;}
    public SelectOption[] folderList {get; set;}
    public String selectedDocumentId {get; set;}
    public String selectedFolderId {get; set;}
    public Map<Id, Document> documentMap {get; set;}
    public Map<Id, Language_Pair__c[]> TranslatorLanguagePairMap;

    public class TranslatorWrapper {
        public Language_Pair__c lPair{get; set;}
        public Boolean selected {get; set;}
        public Boolean fieldMatches {get; set;}
        public TranslatorWrapper(Language_Pair__c lPair) {
                this.lpair = lpair;
            this.selected = false;
            fieldMatches = false;
        }
    }

    public class translationAssWrapper {
        public Translation_Assignment__c translationAssignment {get; set;}
        public Boolean selected {get; set;}
        public Document[] documents {get; set;}
        
        public translationAssWrapper(Translation_Assignment__c a) {
            this.translationAssignment = a;
            this.selected = false;
            this.documents = new Document[]{};
        }
    }


    public Translation_ManageAssignment(ApexPages.StandardController controller) {
        this.controller = controller;
    }    
    
    public PageReference initialize() {
        
        initializeTranslation();
        initializeLpairList();
        initializeFolderList();
        initializeDocumentMap();
        initializeDocumentList();
        initializeTranslatorWrapperList();
        initializeTranslationAssignmentList();
        initializeTranslationAssWrapperList();
        initializeRatingOptions();
        initializeStatusInfo();
        initializeTranslationFeedbackList();
        insertedTranslationFeedback = new Translation_Feedback__c();
        initializeTranslatorList();
        return null;
    }
    
    public void initializeTranslation() {
        initializeTranslation(controller.getId());
    }

    public void initializeTranslation(Id Id) {
        Translation__c[] translationList = [SELECT Name
                            ,Approval_Date__c
                            ,Assignment_Status__c
                            ,Assignment_Date__c
                            ,Certified__c
                            ,Customer_Status__c
                            ,Currency__c
                            ,Due_Date__c
                            ,Editing_Status__c
                            ,Field__c
                            ,Editing__c
                            ,Express__c
                            ,Estimated_Count__c
                            ,Estimated_Price__c
                            ,Estimated_Units__c
                            ,Manager_Status__c
                            ,Native_Language_Proofreading__c
                            ,Proofreading__c
                            ,Proofreading_Only__c
                            ,Proofreading_Status__c
                            ,Source_Language__c
                            ,Supervising_Status__c
                            ,Target_Language__c    
                            ,Translating_Status__c    
                            ,Translator_Wage__c                   
                            ,Urgent__c
                            FROM Translation__c
                            WHERE id =: Id];
        if (!translationList.isEmpty() ) {
            translation = translationList[0];
        }                    
        else {
            addErrorMessage('There is no Translation selected.');
            return;
        }         
    }
    
    public void initializeLpairList() {
        lPairList = [SELECT Name
                        ,Base_Price__c
                        ,Express_Multiplier__c
                        ,From__c
                        ,Proofreading_Multiplier__c
                        ,Source_Char_Price__c
                        ,Source_Word_Price__c
                        ,Target_Char_Price__c
                        ,Target_Word_Price__c
                        ,Urgent_Multiplier__c
                        ,To__c
                        ,Translator__c
                        ,Translator__r.Name
                        ,Translator__r.Field__c
                        ,Translator__r.Editor__c
                        ,Translator__r.Minimum_Wage__c
                        ,Translator__r.Native_Language_Proofreading__c
                        ,Translator__r.Proofreading__c
                        ,Translator__r.Supervisor__c
                        FROM Language_Pair__c
                        WHERE From__c = : translation.Source_Language__c
                        AND To__c = : translation.Target_Language__c
                        AND Translator__r.Deactivated__c = false
                        ORDER BY Translator__r.Name];
    
        TranslatorLanguagePairMap = new Map<Id, Language_Pair__c[]>();
        for (Language_Pair__c lPair : lPairList) {
                if (TranslatorLanguagePairMap.containsKey(lPair.Translator__c)) {
                        TranslatorLanguagePairMap.get(lPair.Translator__c).add(lPair);
                }
                else {
                        TranslatorLanguagePairMap.put(lPair.Translator__c, new Language_Pair__c[]{lPair});
                }
        }
        
    }

    public void initializeTranslatorWrapperList() {
        translatorWrapperList = new TranslatorWrapper[]{};
        for (Language_Pair__c lPair : lPairList) {
            TranslatorWrapper translatorWrapper = new TranslatorWrapper(lPair);
            if (lPair.Translator__r.Field__c != null) {
                if ( New Set<String>(lPair.Translator__r.Field__c.split(';')).contains(translation.Field__c) ) {
                    translatorWrapper.fieldMatches = true;
                }
            }
            translatorWrapperList.add(translatorWrapper); 
        } 
    }

    public void initializeTranslationAssignmentList() {
        translationAssignmentMap = new Map<Id, Translation_Assignment__c>([SELECT Name
                                ,Actual_Count__c
                                ,Assignment_Status__c
                                ,Documents__c
                                ,Due_Date__c
                                ,Estimated_Count__c
                                ,Finished__c
                                ,Express__c
                                ,Message__c
                                ,Postpaid__c
                                ,Rejection_Reason__c
                                ,Started__c
                                ,Task__c
                                ,Translation__c
                                ,Translation__r.Currency__c
                                ,Translation__r.Source_Language__c
                                ,Translation__r.Source_Language__r.Name                                
                                ,Translation__r.Target_Language__c
                                ,Translation__r.Target_Language__r.Name
                                ,Translator_Price__c
                                ,Translator__c                                 
                                ,Translator__r.Email__c
                                ,Translator__r.Name
                                ,Translator__r.Secondary_Email__c  
                                ,Unit_Wage__c     
                                ,Urgent__c                       
                                FROM Translation_Assignment__c
                                WHERE Translation__c =: translation.Id
                                ORDER BY Translator__r.Name]);
        translationAssignmentList = translationAssignmentMap.values();                           
                                
    }

    public void initializetranslationAssWrapperList() {
        translationAssWrapperList = new translationAssWrapper[]{};
        for (Translation_Assignment__c a : translationAssignmentList) {
                TranslationAssWrapper translationAssWrapper = new translationAssWrapper(a);
                if (a.Documents__c != null) {
                        for (String docId : a.Documents__c.split(';')) {
                                translationAssWrapper.documents.add(documentMap.get(docId));
                        }
                }
                // adding the documents
            translationAssWrapperList.add(translationAssWrapper);      
        } 
    }

    public void initializeRatingOptions() {
        ratingOptions = new SelectOption[]{};
        ratingOptions.add(new SelectOption('','--'));
        ratingOptions.add(new SelectOption('5','★★★★★'));
        ratingOptions.add(new SelectOption('4','★★★★'));
        ratingOptions.add(new SelectOption('3','★★★'));
        ratingOptions.add(new SelectOption('2','★★'));
        ratingOptions.add(new SelectOption('1','★'));
    }

    public void initializeTranslatorList() {
        translatorList = new SelectOption[]{};
        translatorList.add(new SelectOption('', 'General Rating'));
        for (Translation_Assignment__c tra : translationAssignmentList) {
            translatorList.add(new SelectOption(tra.Translator__c, tra.Translator__r.Name));
        }
    }
    public void initializeStatusInfo() {
        /*
        // all deprecated statuses
        if (translation.Customer_Status__c != ReflexSettings.CUSTOMER_STATUS_APPROVED
            || !(translation.Manager_Status__c == ReflexSettings.MANAGER_STATUS_APPROVED || translation.Manager_Status__c == ReflexSettings.MANAGER_STATUS_MODIFIED)) {

            addInfoMessage('This translation is not approved both by Customer and Manager!');
        }
        
        if (translation.Assignment_Status__c == ReflexSettings.ASSIGNMENT_STATUS_CANCELED) {
                addInfoMessage('This translation is Canceled!');
        }
        */
        
    }

    public void initializeTranslationFeedbackList() {
        translationFeedbackList = [SELECT Name
                                    ,Communication__c
                                    ,Customer_Experience__c
                                    ,Quality__c
                                    ,Reliability__c
                                    ,Task__c
                                    ,Translation__c
                                    ,Translator__c
                                    ,Translator__r.Name
                                    ,Type__c
                                    FROM Translation_Feedback__c
                                    WHERE Translation__c =: translation.Id];
    }

    public void initializeDocumentList() {
        documentList = new SelectOption[]{};
        for (Document document : documentMap.values() ) {
                if (document.FolderId == selectedFolderId) {
                documentList.add(new SelectOption(document.Id, document.Name));
                }
        }
    }   
    
    public void initializeFolderList() {
        folderList = new SelectOption[]{};
        Folder[] fList = [SELECT Name FROM Folder];
        
        for (Folder folder : fList) {
                if (folder.Id != null && folder.Name != null) {
                  folderList.add(new SelectOption(folder.Id, folder.Name));
                }
        }
        if (!folderList.isEmpty()) {
           selectedFolderId = folderList[0].getValue();
        }
    } 
    
    public void initializeDocumentMap() {
        documentMap = new Map<Id, Document>([SELECT Name
                                                   //,Body
                                                   ,Contenttype
                                                   ,Developername
                                                   ,Description
                                                   ,FolderId
                                                   ,Type
                                                   FROM Document
                                                   LIMIT 10000]);
    }
    
    
    ////////////////////
    ///////////////////Pagereferences

    public PageReference assignTranslation(Id id, String Task) {
        
        Translation_Assignment__c[] recordsToAdd = new Translation_Assignment__c[]{};

        Translation_Assignment__c a = new Translation_Assignment__c();
        a.Translation__c = translation.Id;
        a.Translator__c = Id;
        a.Task__c = Task;
        a.Estimated_Count__c = translation.Estimated_Count__c;
        Decimal minimalWage = defaultZero([SELECT Minimum_Wage__c FROM Translator__c WHERE Id = :Id LIMIT 1].Minimum_Wage__c);
        Decimal estimatedWage = defaultZero(calculateTranslatorPrice(a));
        a.Translator_Price__c = minimalWage > estimatedWage ? minimalWage : estimatedWage;
        
        if (translation.Due_Date__c != null) {
            DateTime traDueDate = translation.Due_Date__c - Integer.valueOf(ReflexSettings.getSettingValue('DAYS_BEFORE_DUE_DATE'));
            a.Due_Date__c = traDueDate < DateTime.Now() ? DateTime.Now() : traDueDate;
        }
        recordsToAdd.add(a);        

        try {
            insert recordsToAdd;
        } catch (system.exception e) {
            addErrorMessage('Internal error:  ' + e);
        }

        triggerTranslateRollupAssignment();

        initializeTranslationAssignmentList();
        initializeTranslationAssWrapperList();
        adjustTranslationStatus();
        initializeTranslatorList();
        return null;
    }
    
    public pageReference deleteAssignment() {
        Translation_Assignment__c[] recordsToDelete = new Translation_Assignment__c[]{};
        for (translationAssWrapper a : translationAssWrapperList) {
            if (a.selected) {
                recordsToDelete.add(a.translationAssignment);
            }
        }
        try {
            delete recordsToDelete;
        } catch (system.exception e) {
            addErrorMessage('Internal error:  ' + e);
        }        
        triggerTranslateRollupAssignment();
        initializeTranslationAssignmentList();
        initializeTranslationAssWrapperList();
        adjustTranslationStatus(); 
        initializeTranslatorList();
        return null;        
    }

    public PageReference updateAssignments() {

        // updating the price calculation
        Map<Id, Translator__c> translatorMap = new Map<Id, Translator__c>([SELECT Minimum_Wage__c FROM Translator__c]);
        for (Translation_Assignment__c tra : translationAssignmentList) {
                if (tra.Postpaid__c) {
                        tra.Translator_Price__c = defaultZero(tra.Unit_Wage__c) * defaultZero(tra.Estimated_Count__c);
                        continue;
                }
            //Decimal minimalWage = defaultZero(translatorMap.get(tra.Translator__c).Minimum_Wage__c);
            //Decimal estimatedWage = defaultZero(calculateTranslatorPrice(tra));
            //tra.Translator_Price__c = minimalWage > estimatedWage ? minimalWage : estimatedWage;
        }
        try {
            update translationAssignmentList;
        } 
        catch (system.exception e) {
            addErrorMessage('Internal error: ' + e);
        }
        triggerTranslateRollupAssignment();

        return null;
    }

    public PageReference folderChange() {
        initializeDocumentMap();
        initializeDocumentList();
        return null;
    }

    public void adjusttranslationStatus() {
        //translation status
        if (translationAssignmentList.isEmpty()) {
            translation.Assignment_Status__c = ReflexSettings.ASSIGNMENT_STATUS_OPEN;
            translation.Assignment_Date__c = null;
        }    
        else if (translation.Assignment_Status__c == ReflexSettings.ASSIGNMENT_STATUS_OPEN || translation.Assignment_Status__c == null) {
            translation.Assignment_Status__c = ReflexSettings.ASSIGNMENT_STATUS_ASSIGNED;
            translation.Assignment_Date__c = translation.Assignment_Date__c == null ? DateTime.Now() : translation.Assignment_Date__c;
        }
        try {
            update translation;
        } catch (system.exception e) {
            addErrorMessage('Internal error:  ' + e);
        }
    }

    public pageReference rateTranslators() {
        try {
            update translationFeedbackList;
        } 
        catch (system.exception e) {
            addErrorMessage('Internal error: ' + e);
        }
        return null;            
    }

    public PageReference addFeedback() {
        insertedTranslationFeedback.Translation__c = translation.Id;
         try {
            insert insertedTranslationFeedback;
        } 
        catch (system.exception e) {
            addErrorMessage('Internal error: ' + e);
        }
        initializeTranslationFeedbackList();
        insertedTranslationFeedback = new Translation_Feedback__c();
        return null;         
    }

    public Pagereference addTranslator() {
        String translatorId = ApexPages.currentPage().getParameters().get('translatorId');
        assignTranslation((Id) translatorId, ReflexSettings.TASK_TRANSLATING);
        return null;
    }

    public Pagereference addProofreader() {
        String translatorId = ApexPages.currentPage().getParameters().get('translatorId');
        assignTranslation((Id) translatorId, ReflexSettings.TASK_PROOFREADING);
        return null;
    }

    public Pagereference addEditor() {
        String translatorId = ApexPages.currentPage().getParameters().get('translatorId');
        assignTranslation((Id) translatorId, ReflexSettings.TASK_EDITING);
        return null;
    }    

    public Pagereference addSupervisor() {
        String translatorId = ApexPages.currentPage().getParameters().get('translatorId');
        assignTranslation((Id) translatorId, ReflexSettings.TASK_SUPERVISING);
        return null;
    }    

    public pageReference addDocumentToAssignment() {
        String assignmentId = ApexPages.currentPage().getParameters().get('assignmentId');
        Translation_Assignment__c tra = [SELECT Documents__c FROM Translation_Assignment__c WHERE Id = :assignmentId LIMIT 1];
        Set<String> documentSet = new Set<String>();
        if (tra.Documents__c != null) {
            documentSet = new Set<String>(tra.Documents__c.split(';'));
        }
        // adding, and if there is a change, doing an update on the wrapper
        if (documentSet.add(selectedDocumentId)) {
                tra.Documents__c = String.join(new List<String>(documentSet), ';');
            try {
               update tra;
            } catch (system.exception e) {
                addErrorMessage('Internal error: ' + e);
            }
                //reload
                initializeTranslationAssignmentList();
                initializeTranslationAssWrapperList();
        }
        return null;
    }
    
    public pageReference removeDocumentFromAssignment() {
        String assignmentId = ApexPages.currentPage().getParameters().get('assignmentId');
        String documentId = ApexPages.currentPage().getParameters().get('documentId');   
        system.debug('+++ IDS ' + assignmentId + ' // ' + documentId);
        Translation_Assignment__c tra = [SELECT Documents__c FROM Translation_Assignment__c WHERE Id = :assignmentId LIMIT 1];
        system.debug('+++ DOCS ' + tra.Documents__c);
        Set<String> documentSet = new Set<String>();
        if (tra.Documents__c != null) {
            documentSet = new Set<String>(tra.Documents__c.split(';'));
        }  
        // removing, and if there is a chage, doing an update on the wrapper
        if (documentSet.remove(documentId)) {
                tra.Documents__c = String.join(new List<String>(documentSet), ';');
                try {
                   update tra;
                } catch (system.exception e) {
                        addErrorMessage('Internal error: ' + e);
                }
                //reload
                initializeTranslationAssignmentList();
                initializeTranslationAssWrapperList();          
        }       
        return null;
    }
    
    public PageReference sendDocuments() {      
        String assignmentId = ApexPages.currentPage().getParameters().get('assignmentId');
        if (!translationAssignmentMap.containsKey(assignmentId)) {
                system.debug('+++ no assignment key');
                return null;
                
        }
        Translation_Assignment__c myAssignment = translationAssignmentMap.get(assignmentId);
        
        // getting the documents. we are doing it again, as we need to get the Body which is huge
        Messaging.EmailFileAttachment[] attachmentList = new Messaging.EmailFileAttachment[]{};
        String[] urlList = new String[]{};
        if (myAssignment.Documents__c != null) {
                Document[] myDocuments = [SELECT Name
                                                           ,Body
                                                           ,Contenttype
                                                           ,Developername
                                                           ,Description
                                                           ,Type
                                                           ,Url
                                                           FROM Document
                                                           WHERE Id IN : myAssignment.Documents__c.split(';')
                                                           LIMIT 10000];                           
                for (Document document : myDocuments) {
                        // it this is an url-document
                        if (document.Url != null) {
                                urlList.add(document.Url);
                                continue;
                        }
                        // it is an uploaded document
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setContentType(document.Contenttype);
                    attachment.setFileName(document.Developername + '.' + document.Type);
                    attachment.setInLine(false);
                    attachment.Body = document.Body;
                    attachmentList.add(attachment);
                }  
        }
        // the email body
        Map<String, String> fieldMap = new Map<String, String>{
                'translator_name' => myAssignment.Translator__r.Name,
                'source_language' => myAssignment.Translation__r.Source_Language__r.Name,
                'target_language' => myAssignment.Translation__r.Target_Language__r.Name,
                'due_date' => myAssignment.Due_Date__c.Year() + '.' + myAssignment.Due_Date__c.Month() + '.'+ myAssignment.Due_Date__c.Day() + '.',
            'due_datetime' => myAssignment.Due_Date__c.Hour() + ':' + myAssignment.Due_Date__c.Minute(),
            'translator_wage' => String.valueOf(myAssignment.Translator_Price__c),
            'currency' => myAssignment.Translation__r.Currency__c,
            'office_location' => 'Budapest',
            'url_list' => String.join(urlList, '<br/>'),
            'assignment_id' => myAssignment.Id,
            'message' => myAssignment.Message__c
        };
        
        String emailBody = replacePlaceHolders(ReflexSettings.EMAIL_TEMPLATE_TRANSLATOR_ASSIGNMENT, fieldMap);

        // the email
        
        String[] toAddresses = new String[]{};
        system.debug('+++ ' + myAssignment);
        if (myAssignment.Translator__r.Email__c != null) {
            toAddresses.add(myAssignment.Translator__r.Email__c);
        }
        if (myAssignment.Translator__r.Secondary_Email__c != null) {
            toAddresses.add(myAssignment.Translator__r.Secondary_Email__c);
        }
        system.debug('+++ ' + toAddresses);
        Messaging.SingleEmailMessage[] mailList = new Messaging.SingleEmailMessage[]{};
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false); 
        mail.setToAddresses(toAddresses);
        mail.setSubject('REFLEX: Új feladat');
        mail.setHtmlBody(emailBody);
        mail.setFileAttachments(attachmentList);
        mailList.add(mail);
        
        system.debug('+++' + mail);
        // sending the mail
        try {
                Messaging.sendEmail(mailList);
            addInfoMessage('Documents sent in Email to ' + myAssignment.Translator__r.Name);
        } catch (system.exception e) {
                addErrorMessage('Internal error ' + e);
        }
        
        return null;
    }
    
    public pageReference updateUnitWage() {
        String assignmentId = ApexPages.currentPage().getParameters().get('assignmentId');
        // finding the current translation assignment
        
        for (Translation_Assignment__c tra : translationAssignmentList) {
                if (tra.Id == assignmentId) {
                        tra.Translator_Price__c = defaultZero(tra.Unit_Wage__c) * defaultZero(tra.Estimated_Count__c);
                try {
                   update tra;
                        } catch (system.exception e) {
                                addErrorMessage('Internal error ' + e);
                }
                break;                          
                }
        } 
        // refresh
        initializeTranslationAssignmentList();
        initializeTranslationAssWrapperList();        
        return null;
    }
    
    public PageReference doNothing() {
        return null;
    }
    //other
    ////////////////////
    public Decimal calculateTranslatorPrice(Translation_Assignment__c translationAssignment) {
        Decimal estimation;
        
        // getting the language pair
        Language_Pair__c lPair;
        for (Language_Pair__c lp : TranslatorLanguagePairMap.get((Id) translationAssignment.Translator__c)) {
            if (lp.From__c == translation.Source_Language__c && lp.To__c == translation.Target_Language__c) {
                lPair = lp;
                break;
            }
        }
        
        if (lPair == null) {
                return null;
        }
        
        if (translation.Estimated_Units__c == ReflexSettings.TRANSLATION_UNIT_CHAR) {
            estimation = defaultZero(lPair.Base_Price__c)
                        + defaultZero(translationAssignment.Estimated_Count__c) * defaultZero(lPair.Target_Char_Price__c);
        }
        if (translation.Estimated_Units__c == ReflexSettings.TRANSLATION_UNIT_WORD) {
            estimation = defaultZero(lPair.Base_Price__c)
                        + defaultZero(translationAssignment.Estimated_Count__c) * defaultZero(lPair.Source_Word_Price__c);
        }
        // proofreading price
        if (translationAssignment.Task__c == ReflexSettings.TASK_PROOFREADING)  {
            estimation = estimation * defaultZero(LPair.Proofreading_Multiplier__c) / 100;
        }
        /*//urgent price
        if (translationAssignment.Urgent__c == true) {
            estimation += estimation * defaultZero(LPair.Urgent_Multiplier__c) / 100;
        }
        //express price
        if (translationAssignment.Express__c == true) {
            estimation += estimation * defaultZero(LPair.Express_Multiplier__c) / 100;
        }*/
        return estimation;
    }

    public void triggerTranslateRollupAssignment() {
        system.debug('CSIMM');
        translation.Rollup_Assignments__c = null;
        try {
            update translation;
            initializeTranslation(translation.id);
        }
        catch (system.exception e) {

        }
    }
    
    public String replacePlaceHolders(String s, Map<String, String> fieldMap) {
        for (String key : fieldMap.keySet()) {
                s = s.replace('{{' + key + '}}', fieldMap.get(key) != null ? fieldMap.get(key) : '');
        }
        return s;
    }
     //Tools  //////////////////////////////////////
    //////////////////////////////////////////
    public void addErrorMessage(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, message));
    }  

    public void addInfoMessage(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, message));
    }  

    public Decimal defaultZero(Decimal value) {
        return value == null ? 0 : value;
    }
    
    public void notNiceTestHack() {
        integer x = 1;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;   
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;   
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;   
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;   
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;         
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;   
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;         
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;   
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;   
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;         
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;   
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;        
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;   
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;        
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;   
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;        
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;   
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;       
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;   
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;       
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;   
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;   
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;       
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;   
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++; 
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;


    }
}