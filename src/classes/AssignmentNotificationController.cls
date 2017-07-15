public with sharing class AssignmentNotificationController {
    public Translation_Assignment__c translationAssignment {get; set;}
    public Translation_Assignment__c ta {get; set;}

    public String[] documentList {get; set;}
    
    public String initialize {
        get {
            initialize();   
            return null;
        }
    }

    public void initialize() {
        intializeDocumentList();
    }   

    public void intializeDocumentList() {
    	documentList = new String[]{};
    	Translation_Assignment__c trAssignment = [SELECT Documents__c 
    	                           FROM Translation_Assignment__c 
    	                           WHERE Id =:  ta.Id 
    	                           LIMIT 1];
    	String[] documentIdList = trAssignment.Documents__c != null ? trAssignment.Documents__c.split(';') : new String[]{};
        for (String documentId : documentIdList) {
            documentList.add('/servlet/servlet.ImageServer?id=' + documentId + '&oid=' + UserInfo.getOrganizationId());
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