public virtual class TranslationAssignmentTrigger extends SobjectTrigger {
    // Constructor
    public TranslationAssignmentTrigger(Translation_Assignment__c[] sobjectOldList, Translation_Assignment__c[] sobjectNewList) {
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
        return getIsMatching((Translation_Assignment__c) sobjectOld, (Translation_Assignment__c) sobjectNew);
    }
    
    public override void execute(Sobject[] sobjectList, Boolean doUpdate) {
        if (sobjectList != null && sobjectList.isEmpty() == false) {
            execute((Translation_Assignment__c[]) sobjectList, doUpdate);
        }
    }
    
    // Virtuals
    
    public virtual Boolean getIsMatching(Translation_Assignment__c sobjectOld, Translation_Assignment__c sobjectNew) {
        return true;
    }
    
    public virtual void execute(Translation_Assignment__c[] sobjectList, Boolean doUpdate) {
        
    }
}