public virtual class TranslationFeedbackTrigger extends SobjectTrigger {
    // Constructor
    public TranslationFeedbackTrigger(Translation_Feedback__c[] sobjectOldList, Translation_Feedback__c[] sobjectNewList) {
        super(sobjectOldList, sobjectNewList);
    }
    
    // Overrides
    
    public override Boolean getIsMatching(Sobject sobjectOld, Sobject sobjectNew) {
        integer x = 1;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;          
        return getIsMatching((Translation_Feedback__c) sobjectOld, (Translation_Feedback__c) sobjectNew);
    }
    
    public override void execute(Sobject[] sobjectList, Boolean doUpdate) {
        if (sobjectList != null && sobjectList.isEmpty() == false) {
            execute((Translation_Feedback__c[]) sobjectList, doUpdate);
        }
    }
    
    // Virtuals
    
    public virtual Boolean getIsMatching(Translation_Feedback__c sobjectOld, Translation_Feedback__c sobjectNew) {
        return true;
    }
    
    public virtual void execute(Translation_Feedback__c[] sobjectList, Boolean doUpdate) {
        
    }
	
}