public virtual class TranslationTrigger extends SobjectTrigger {
    // Constructor
    public TranslationTrigger(Translation__c[] sobjectOldList, Translation__c[] sobjectNewList) {
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
        return getIsMatching((Translation__c) sobjectOld, (Translation__c) sobjectNew);
    }
    
    public override void execute(Sobject[] sobjectList, Boolean doUpdate) {
        if (sobjectList != null && sobjectList.isEmpty() == false) {
            execute((Translation__c[]) sobjectList, doUpdate);
        }
    }
    
    // Virtuals
    
    public virtual Boolean getIsMatching(Translation__c sobjectOld, Translation__c sobjectNew) {
        return true;
    }
    
    public virtual void execute(Translation__c[] sobjectList, Boolean doUpdate) {
        
    }
	
}