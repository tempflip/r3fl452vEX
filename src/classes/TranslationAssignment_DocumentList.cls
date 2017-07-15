public without sharing class TranslationAssignment_DocumentList {
    public Translation_Assignment__c translationAssignment {get; set;}
    public Document[] documentList {get; set;}
    public String chatterMessage {get; set;}
    
    public TranslationAssignment_DocumentList() {}
    
    public void initialize() {
        String id = ApexPages.currentPage().getParameters().get('id');
        initializeTranslationAssignment(id);
        intializeDocumentList();
    }   


    public void initializeTranslationAssignment(Id id) {
        translationAssignment = [SELECT Name
                                    ,Assignment_Status__c
                                    ,Documents__c
                                    ,Due_Date__c
                                    ,Message__c
                                    ,Postpaid__c
                                    ,Rejection_Reason__c
                                    ,Task__c
                                    ,Translation__r.Name
                                    ,Translation__r.Estimated_Count__c
                                    ,Translation__r.Estimated_Units__c
                                    ,Translation__r.Source_Language__r.Name
                                    ,Translation__r.Target_Language__r.Name
                                    ,Translator_Price__c
                                    ,Translation__r.Currency__c
                                    ,Translation__r.Due_Date__c
                                    ,Translator__r.Name
                                    FROM Translation_Assignment__c
                                    WHERE Id = :id
                                    LIMIT 1];
    }
    
    public void intializeDocumentList() {

        String[] documentIdList = translationAssignment.Documents__c != null ? translationAssignment.Documents__c.split(';') : new String[]{};
        documentList = [SELECT Name
                        ,Url
                        FROM Document
                        WHERE Id IN : documentIdList
                        AND Url != null];   
    }
    
    ////////Pagereferences
    /////////////////////////////
     
    public PageReference accept() {
        translationAssignment.Assignment_Status__c = ReflexSettings.ASSIGNMENT_STATUS_ACCEPTED;
        try {
                update translationAssignment;
        } catch (system.exception e) {}

        // new chatter feed entry
        FeedItem post = new FeedItem();
        post.ParentId =  translationAssignment.Translation__c;
        post.Body = 'Translation has been accepted by ' 
                        + translationAssignment.Translator__r.Name;

        try {
            insert post;
        } catch (system.exception e) {}
                
        return null;
    }
    
    public PageReference reject() {
        translationAssignment.Assignment_Status__c = ReflexSettings.ASSIGNMENT_STATUS_REJECTED;
        try {
            update translationAssignment;
        } catch (system.exception e) {}
        
        // new chatter feed entry
        FeedItem post = new FeedItem();
        post.ParentId =  translationAssignment.Translation__c;
        post.Body = 'Translation has been rejected by ' 
                        + translationAssignment.Translator__r.Name 
                        + 'for the following reason: \n'
                        + translationAssignment.Rejection_Reason__c;
        try {
                insert post;
        } catch (system.exception e) {}
        return null;
    }  
    
    public PageReference sendChatterMessage() {
    // new chatter feed entry
        FeedItem post = new FeedItem();
        post.ParentId =  translationAssignment.Translation__c;
        post.Body = 'Message from '
                    + translationAssignment.Translator__r.Name 
                    + ' : '
                    + chatterMessage;
        //try {
            //new WithoutSharing().forceInsert(new FeedItem[]{post});
        //} catch (system.exception e) {}         
        chatterMessage = '';
        return null;    
    }  
}