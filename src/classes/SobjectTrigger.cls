public virtual with sharing class SobjectTrigger {
    Sobject[] sobjectNewList;
    Sobject[] sobjectOldList;
    Map<Id, Sobject> sobjectOldListMap = new Map<Id, Sobject> {};
    
    public SobjectTrigger(Sobject[] sobjectOldList, Sobject[] sobjectNewList) {
        this.sobjectOldList = sobjectOldList == null ? new Sobject[] {} : sobjectOldList.clone();
        this.sobjectNewList = sobjectNewList == null ? new Sobject[] {} : sobjectNewList.clone();
        
        // Initialize map
        for(Sobject sobjectOld : this.sobjectOldList) {
            if (sobjectOld.Id != null) {
                sobjectOldListMap.put(sobjectOld.Id, sobjectOld);
            }
        }
    }
    
    public Boolean getIsDifferent(Sobject sobjectOld, Sobject sobjectNew, Schema.SobjectField sobjectField) {
        return sobjectOld == null || sobjectNew == null
            || sobjectOld.get(sobjectField) == sobjectNew.get(sobjectField);
    } 
    
    public virtual Boolean getIsMatching(Sobject sobjectOld, Sobject sobjectNew) {
        return true;
    }
    
    public void execute() {
        Sobject[] sobjectMatchingList = new Sobject[] {};
        
        for(Sobject sobjectNew : sobjectNewList) {
            if (getIsMatching(sobjectOldListMap.get(sobjectNew.Id), sobjectNew)) {
                sobjectMatchingList.add(sobjectNew);
            }
        }
        
        if (sobjectMatchingList.isEmpty() == false) {
            execute(sobjectMatchingList, Trigger.isExecuting == true && Trigger.isAfter == true);
        }
    }
    
    public virtual void execute(Sobject[] sobjectMatchingList, Boolean doUpdate) {
        // nothing here.
    }
    
    //
    // Utility methods
    //
    
    public Decimal defaultZero(Decimal value) {
        return defaultOf(value, 0.0);
    }
    
    public Decimal defaultOf(Decimal value, Decimal defaultValue) {
        return value == null ? defaultValue : value;
    }
}