public with sharing class ReflexSettings {
    public static final Map<String, Settings__c> SETTINGS_MAP = Settings__c.getAll().clone();
    
    public static String getSettingValue(String name) {
        return SETTINGS_MAP.get(name) == null ? null : SETTINGS_MAP.get(name).Value__c;
    }

    public static String setSettingValue(String name, Boolean data) {
        return setSettingValue(name, data == true ? 'true' : 'false');
    }

    public static String setSettingValue(String name, String data) {
        Settings__c setting = SETTINGS_MAP.get(name);

        if (setting == null) {
            setting = new Settings__c();
            setting.Name = name;

            // Add to collection
            SETTINGS_MAP.put(name, setting);
        }

        setting.Value__c = data;
        upsert setting;
        return setting.Value__c;
    }

    // org defaults
    public static final string TRANSLATION_UNIT_CHAR = 'characters';
    public static final string TRANSLATION_UNIT_WORD = 'words';

    public final static string JOB_STATUS_PENDING = 'Pending';
	public final static string JOB_STATUS_UNASSIGNED = 'Unassigned';
	public final static string JOB_STATUS_ASSIGNED =  'Assigned';
	public final static string JOB_STATUS_INPROGRESS =  'In Progress';
	public final static string JOB_STATUS_COMPLETED = 'Completed';
    public final static string JOB_STATUS_APPROVED = 'Approved';

    public final static string ASSIGNMENT_STATUS_OPEN = 'Open';
	public final static string ASSIGNMENT_STATUS_ASSIGNED = 'Assigned';
    public final static string ASSIGNMENT_STATUS_ACCEPTED = 'Accepted';	
    public final static string ASSIGNMENT_STATUS_COMPLETED = 'Completed';
    public final static string ASSIGNMENT_STATUS_REJECTED = 'Rejected';
    public final static string ASSIGNMENT_STATUS_REMOVED = 'Removed';
    public final static string ASSIGNMENT_STATUS_CANCELED = 'Canceled';

    public final static string TASK_TRANSLATING = 'Translating';
    public final static string TASK_PROOFREADING = 'Proofreading';
    public final static string TASK_EDITING = 'Editing';
    public final static string TASK_SUPERVISING = 'Supervising';

    public final static string TASK_STATUS_ASSIGNED = 'Assigned';
    public final static string TASK_STATUS_ACCEPTED = 'Accepted';
    public final static string TASK_STATUS_COMPLETED = 'Completed';
    public final static string TASK_STATUS_REJECTED = 'Rejected';

    public final static string CUSTOMER_STATUS_APPROVED = 'Approved';
    public final static string MANAGER_STATUS_APPROVED = 'Approved';
    public final static string MANAGER_STATUS_MODIFIED = 'Modified';

    public static final string TRANSLATION_EXTRA_STATUS_NOTREQUIRED = 'Not Required';
    public static final string TRANSLATION_EXTRA_STATUS_REQUIRED = 'Required';
    public static final string TRANSLATION_EXTRA_STATUS_COMPLETED = 'Completed';

    public static final string PRICE_BASED_SOURCE = 'Source';
    public static final string PRICE_BASED_TARGET = 'Target';
    

    public final static string DEFAULT_INVOICING_COUNTRY_CODE = 'HU';
    
    public final static string DEFAULT_PRODUCT_NAME1 = 'Egyedi fordítás';

    public final static decimal DEFAULT_DUE_DATE = 5;
    
    public static final String ORG_HOST = 'http://reflex.force.com';

    // Email templates
    public final static String EMAIL_TEMPLATE_TRANSLATOR_ASSIGNMENT = 'Kedves {{translator_name}}!<p/>Légy szíves, készítsd el a csatolt dokumentum(ok) {{source_language}} - {{target_language}} fordítását, {{due_date}}, {{due_datetime}} határidővel.<br/>A munka nettó fordítási díja: {{translator_wage}} {{currency}}.<p/>Fáradozásodat előre is köszönjük.<p/><p/>Kérlek, a következő linken jelezd, hogy elfogadod-e a munkát: <p/>'+ ORG_HOST + '/documentList?id={{assignment_id}}<p/>{{message}}<p/>Üdvözlettel,<p/>Reflex Fordítóiroda<br/>{{office_location}}<p/> Online elérhető dokumentumok:<p/> {{url_list}}';
    public final static String EMAIL_TEMPLATE_TASK_REJECTION = 'Kedves {{user_name}}!<p/>Sajnos, a {{translation_name}} munkaszámú {{task}} nem tudom vállalni a következő ok miatt:<p/>{{rejection_reason}}<p/>Kérem megértéseteket.<p/>Üdvözlettel,<p/>{{translator_name}}';
       
}