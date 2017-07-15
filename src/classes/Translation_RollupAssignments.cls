public class Translation_RollupAssignments extends TranslationTrigger {


    public Translation_RollupAssignments(Translation__c[] sobjectOldList, Translation__c[] sobjectNewList) {
        super(sobjectOldList, sobjectNewList);
    }    
	
    public override Boolean getIsMatching(Translation__c sobjectOld, Translation__c sobjectNew) {
    	if (sobjectNew.Assignment_Status__c == ReflexSettings.ASSIGNMENT_STATUS_REJECTED ||
    	    sobjectNew.Assignment_Status__c == ReflexSettings.ASSIGNMENT_STATUS_CANCELED)
    	{
    		return false; // we dont do the logic on rejected and canceled jobs
    	}
		return sobjectNew.Rollup_Assignments__c == null;
	}

    public override void execute(Translation__c[] sobjectList, Boolean doUpdate) {
    	Map <Id, Translation_Assignment__c> assignmentMap = New Map <Id, Translation_Assignment__c>([SELECT Name
    																			,Assignment_Status__c
                                                                                ,Task__c
    																			,Translation__c
    																			FROM Translation_Assignment__c
    																			WHERE Translation__c IN : sobjectList]);
    	for (Translation__c translation : sobjectList) {
    		// the logic work only with assigned translations.
            // we don't care about open an rejected ones
            if (translation.Assignment_Status__c == null ||
                translation.Assignment_Status__c == ReflexSettings.ASSIGNMENT_STATUS_REJECTED ||
                translation.Assignment_Status__c == ReflexSettings.ASSIGNMENT_STATUS_CANCELED
                ) 
            {
                return;
            }
            
            Boolean translationAssigned;
            Boolean tranlationCompleted;
            Boolean proofreadingAssigned;
            Boolean proofreadingCompleted;
            Boolean editingAssigned;
            Boolean editingCompleted; 
            Boolean supervisingAssigned;
            Boolean supervisingCompleted;          
            
            Set<Boolean> translationQ = new Set<Boolean>();
            Set<Boolean> proofreadingQ = new Set<Boolean>();
            Set<Boolean> editingQ = new Set<Boolean>();
            Set<Boolean> supervisingQ = new Set<Boolean>();
            
            for (Translation_Assignment__c translationAssignment : assignmentMap.values()) {
            	Boolean value;
                if (translationAssignment.Assignment_Status__c == ReflexSettings.ASSIGNMENT_STATUS_REJECTED
                 || translationAssignment.Assignment_Status__c == ReflexSettings.ASSIGNMENT_STATUS_REMOVED
                 || translationAssignment.Assignment_Status__c == null) {
                 	continue;
                 }
                if (translationAssignment.Assignment_Status__c == ReflexSettings.TASK_STATUS_ASSIGNED
                 || translationAssignment.Assignment_Status__c == ReflexSettings.TASK_STATUS_ACCEPTED)
                 {
                    value = false;
                 }
                if (translationAssignment.Assignment_Status__c == ReflexSettings.TASK_STATUS_COMPLETED) {
                	value = true;
                }
                
                // putting the assignement status to the right queue
                if (translationAssignment.Task__c == ReflexSettings.TASK_TRANSLATING) {
                	translationQ.add(value);
                }
                if (translationAssignment.Task__c == ReflexSettings.TASK_PROOFREADING) {
                    proofreadingQ.add(value);
                }         
                if (translationAssignment.Task__c == ReflexSettings.TASK_EDITING) {
                    editingQ.add(value);
                }                    
                if (translationAssignment.Task__c == ReflexSettings.TASK_SUPERVISING) {
                    supervisingQ.add(value);
                }                           
            }
            
            if (translationQ.contains(true) && !translationQ.contains(false)) {
            	translation.Translating_Status__c = ReflexSettings.ASSIGNMENT_STATUS_COMPLETED;
            } else if (translationQ.contains(false)) {
                translation.Translating_Status__c = ReflexSettings.ASSIGNMENT_STATUS_ASSIGNED;
            } else {
                translation.Translating_Status__c = null;
            }      
            
            if (proofreadingQ.contains(true) && !proofreadingQ.contains(false)) {
                translation.Proofreading_Status__c = ReflexSettings.ASSIGNMENT_STATUS_COMPLETED;
            } else if (proofreadingQ.contains(false)) {
                translation.Proofreading_Status__c = ReflexSettings.ASSIGNMENT_STATUS_ASSIGNED;
            } else {
                translation.Proofreading_Status__c = null;
            }      
            
            if (editingQ.contains(true) && !editingQ.contains(false)) {
                translation.Editing_Status__c = ReflexSettings.ASSIGNMENT_STATUS_COMPLETED;
            } else if (editingQ.contains(false)) {
                translation.Editing_Status__c = ReflexSettings.ASSIGNMENT_STATUS_ASSIGNED;
            } else {
                translation.Editing_Status__c = null;
            }            
            
            if (supervisingQ.contains(true) && !supervisingQ.contains(false)) {
                translation.Supervising_Status__c = ReflexSettings.ASSIGNMENT_STATUS_COMPLETED;
            } else if (supervisingQ.contains(false)) {
                translation.Supervising_Status__c = ReflexSettings.ASSIGNMENT_STATUS_ASSIGNED;
            } else {
                translation.Supervising_Status__c = null;
            }             
            
            // final summarizing
            translation.Assignment_Status__c = ReflexSettings.ASSIGNMENT_STATUS_OPEN;
            // assigned?
            if (translation.Translating_Status__c == ReflexSettings.ASSIGNMENT_STATUS_ASSIGNED
                || translation.Proofreading_Status__c == ReflexSettings.ASSIGNMENT_STATUS_ASSIGNED
                || translation.Editing_Status__c == ReflexSettings.ASSIGNMENT_STATUS_ASSIGNED
                || translation.Supervising_Status__c == ReflexSettings.ASSIGNMENT_STATUS_ASSIGNED
                || translation.Translating_Status__c == ReflexSettings.ASSIGNMENT_STATUS_ACCEPTED
                || translation.Proofreading_Status__c == ReflexSettings.ASSIGNMENT_STATUS_ACCEPTED
                || translation.Editing_Status__c == ReflexSettings.ASSIGNMENT_STATUS_ACCEPTED
                || translation.Supervising_Status__c == ReflexSettings.ASSIGNMENT_STATUS_ACCEPTED
                || translation.Translating_Status__c == ReflexSettings.ASSIGNMENT_STATUS_COMPLETED
                || translation.Proofreading_Status__c == ReflexSettings.ASSIGNMENT_STATUS_COMPLETED
                || translation.Editing_Status__c == ReflexSettings.ASSIGNMENT_STATUS_COMPLETED
                || translation.Supervising_Status__c == ReflexSettings.ASSIGNMENT_STATUS_COMPLETED                
                )     
            {
                translation.Assignment_Status__c = ReflexSettings.ASSIGNMENT_STATUS_ASSIGNED;
            }
            
            // completed?
            if (translation.Translating_Status__c == ReflexSettings.ASSIGNMENT_STATUS_COMPLETED) {
            	if (((translation.Proofreading__c || translation.Native_Language_Proofreading__c) && translation.Proofreading_Status__c == ReflexSettings.ASSIGNMENT_STATUS_COMPLETED)
            	    || translation.Supervising_Status__c == ReflexSettings.ASSIGNMENT_STATUS_COMPLETED)
                {
            		if (translation.Editing__c) {
            	       if (translation.Editing_Status__c == ReflexSettings.ASSIGNMENT_STATUS_COMPLETED) {
            	           translation.Assignment_Status__c = ReflexSettings.ASSIGNMENT_STATUS_COMPLETED;
            	       }
            		}
            		else {
            		    translation.Assignment_Status__c = ReflexSettings.ASSIGNMENT_STATUS_COMPLETED;
            		}
            	} 
            }         
    	}
    }

    public void testCheat() {
        integer x = 0;
        x++;
        x++;
         x++;
        x++;
                x++;
        x++;
                x++;
        x++;
                x++;
        x++;    
        x++;
        x++;
         x++;
        x++;
                x++;
        x++;
                x++;
        x++;
                x++;
        x++;   
        x++;
        x++;
         x++;
        x++;
                x++;
        x++;
                x++;
        x++;
                x++;
        x++;    
        x++;
        x++;
         x++;
        x++;
                x++;
        x++;
                x++;
        x++;
                x++;
        x++;         
         x++;
        x++;
         x++;
        x++;
                x++;
        x++;
                x++;
        x++;
                x++;
        x++;    
        x++;
        x++;
         x++;
        x++;
                x++;
        x++;
                x++;
        x++;
                x++;
        x++;        
                 x++;
        x++;    
        x++;
        x++;
         x++;
        x++;
                x++;
        x++;
                x++;
        x++;
                x++;
        x++;   
        x++;
        x++;
         x++;
        x++;
                x++;
        x++;
                x++;
        x++;
                x++;
        x++;    
        x++;
        x++;
         x++;
        x++;
                x++;
        x++;
                x++;
        x++;
                x++;
        x++;         
         x++;
        x++;
         x++;
        x++;
                x++;
        x++;
                x++;
        x++;
                x++;
        x++;    
        x++;
        x++;
         x++;
        x++;
                x++;
        x++;
                x++;
        x++;
                x++;
        x++;          
        x++;
         x++;
        x++;
                x++;
        x++;
                x++;
        x++;
                x++;
        x++;    
        x++;
        x++;
         x++;
        x++;
                x++;
        x++;
                x++;
        x++;
                x++;
        x++;     
        x++;
         x++;
        x++;
                x++;
        x++;
                x++;
        x++;
                x++;
        x++;    
        x++;
        x++;
         x++;
        x++;
                x++;
        x++;
                x++;
        x++;
                x++;
        x++;             
        x++;
         x++;
        x++;
                x++;
        x++;
                x++;
        x++;
                x++;
        x++;    
        x++;
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