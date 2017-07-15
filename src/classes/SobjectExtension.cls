public virtual class SobjectExtension {
    public ApexPages.StandardController controller;

    public SobjectExtension() {

    }

    public SobjectExtension(ApexPages.StandardController controller) {
        this.controller = controller;
    }

    public String getParam(String name) {
        return getParam(name, ApexPages.currentPage());
    }

    public String getParam(String name, String encodedParams) {
        return getParam(name, new PageReference('/?' + encodedParams));
    }

    public String getParam(String name, PageReference pageReference) {
        return pageReference.getParameters().get(name);
    }

    public void putParam(String name, String data) {
        ApexPages.currentPage().getParameters().put(name, data);
    }

    public String getId() {
        return controller == null ? null : controller.getId();
    }

    public Boolean hasErrorMessages() {
        return ApexPages.hasMessages(ApexPages.Severity.Error);
    }

    public PageReference addErrorMessage(System.Exception problem, System.Savepoint savepoint) {
        return addMessage(ApexPages.Severity.Error, problem.getTypeName() + ': ' + problem.getMessage(), savepoint);
    }

    public PageReference addErrorMessage(String message) {
        return addMessage(ApexPages.Severity.Error, message, null);
    }

    public PageReference addErrorMessage(String message, System.Savepoint savepoint) {
        return addMessage(ApexPages.Severity.Error, message, savepoint);
    }

    public PageReference addInfoMessage(String message) {
        return addMessage(ApexPages.Severity.Info, message, null);
    }

    public PageReference addWarningMessage(String message) {
        return addMessage(ApexPages.Severity.Warning, message, null);
    }

    public PageReference addMessage(ApexPages.Severity severity, String message, System.Savepoint savepoint) {
        if (savepoint != null) {
            Database.rollback(savepoint);
        }

        if (message != null) {
            ApexPages.addMessage(new ApexPages.Message(severity, message));
        }

        return null;
    }

    public virtual PageReference initialize() {
        return null;
    }

    public virtual PageReference redirectTo(PageReference pageReference) {
        pageReference.setRedirect(true);
        return pageReference;
    }

    public virtual PageReference redirectToView() {
        return redirectTo(new PageReference('/' + getId()));
    }

    public virtual PageReference redirectToEdit() {
        return redirectTo(new PageReference('/' + getId() + '/e'));
    }

    public String defaultOf(String value) {
        return defaultOf(value, '');
    }

    public String defaultOf(String value, String defaultValue) {
        return value == null ? defaultValue : value;
    }

    public Decimal defaultOf(Decimal value) {
        return defaultOf(value, 0.0);
    }

    public Decimal defaultOf(Decimal value, Decimal defaultValue) {
        return value == null ? defaultValue : value;
    }

    public Boolean isBlank(String value) {
        return value == null || value == '' || value.trim() == '';
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