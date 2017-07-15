@isTest
public with sharing class ReflexTests {
	public ReflexTests() {
		initializeCustomSettings();
	}

	public Account[] accountList = new Account[] {};
	public Language__c[] languageList = new Language__c[] {};
	public Pricing__c[] pricingList = new Pricing__c[] {};
	public Region_Pricing__c[] regionPricingList = new Region_Pricing__c[] {};
	public Translator__c[] translatorList = new Translator__c[] {};
	public Translation__c[] translationList = new Translation__c[] {};
	public Language_Pair__c[] languagePairList = new Language_Pair__c[] {};
	public Translation_Assignment__c[] translationAssignmentList = new Translation_Assignment__c[] {};
    public Account_Pricing__c[] accountPricingList = new Account_Pricing__c[] {};
    
    private Sobject getLatestSobject(Sobject[] sobjectList) {
        return sobjectList.isEmpty() ? null : sobjectList[sobjectList.size() - 1];
    }

    public Account getAccount() {
    	return (Account) getLatestSobject(accountList);
    }

    public Language__c getLanguage() {
    	return (Language__c) getLatestSobject(languageList);
    }

    public Pricing__c getPricing() {
    	return (Pricing__c) getLatestSobject(pricingList);
    }

    public Region_Pricing__c getRegionPricing() {
    	return (Region_Pricing__c) getLatestSobject(regionPricingList);
    }
    
    public Translator__c getTranslator() {
    	return (Translator__c) getLatestSobject(translatorList);
    }

    public Translation__c getTranslation() {
    	return (Translation__c) getLatestSobject(translationList);
    }

    public Language_Pair__c getLanguagePair() {
    	return (Language_Pair__c) getLatestSobject(languagePairList);
    }

    public Translation_Assignment__c getTranslationAssignment() {
        return (Translation_Assignment__c) getLatestSobject(translationAssignmentList);
    }

    public Account_Pricing__c getAccountPricing() {
        return (Account_Pricing__c) getLatestSobject(accountPricingList);
    }

    // inserts

    public void insertAccount() {
    	Account a = new Account();
    	a.Name = 'Account Accontovich';
    	insert a;
    	accountList.add(a);
    }

    public void insertLanguage() {
    	Language__c l = new Language__c();
    	l.Name = 'English';
    	l.Language_Code__c = 'EN';
    	l.Pricing__c = getPricing().Id;
    	insert l;
    	languageList.add(l);
    }

    public void insertPricing() {
    	Pricing__c p = new Pricing__c();
    	p.Name = 'myPricing1';
    	insert p;
    	pricingList.add(p);
    }

    public void insertRegionPricing() {
    	Region_Pricing__c rp = new Region_Pricing__c();
    	rp.Pricing__c = getPricing().Id;
    	rp.Region__c = 'HU';
    	rp.Base_Price__c = 1000;
    	rp.Source_Char_Price__c = 1;
    	rp.Target_Char_Price__c = 1;
    	rp.Source_Word_Price__c = 1;
    	rp.Target_Word_Price__c = 1;
    	rp.Urgent_Multiplier__c = 30;
     	rp.Express_Multiplier__c = 30;
     	rp.Proofreading_Multiplier__c = 30;
     	insert rp;
     	regionPricingList.add(rp);
    }
    
    public void insertAccountPricing() {
    	Account_Pricing__c a = new Account_Pricing__c();
    	a.Source_Language__c = getLanguage().Id;
    	a.Target_Language__c = getLanguage().Id;
        
    	insert a;
    	accountPricingList.add(a);
    }

    public void insertTranslation() {
    	Translation__c t = new Translation__c();
    	t.Account__c = getAccount().Id;
    	t.Estimated_Count__c = 3000;
    	t.Estimated_Units__c = ReflexSettings.TRANSLATION_UNIT_CHAR;
    	t.Source_Language__c = languageList[languageList.size()-1].Id;
    	t.Target_Language__c = languageList[languageList.size()-2].Id;
    	t.Due_Date__c = Datetime.Now() + 5;
    	insert t;
    	translationList.add(t);
    }

    public void insertTranslator() {
    	Translator__c t = new Translator__c();
    	t.Name = 'The Translator';
    	t.Proofreading__c = true;
    	t.Editor__c = true;
    	insert t;
    	translatorList.add(t);
    }

    public void insertTranslationAssignment() {
    	Translation_Assignment__c tra = new Translation_Assignment__c();
    	tra.Translation__c = getTranslation().Id;
    	tra.Translator__c = getTranslator().Id;
    	insert tra;
    	translationAssignmentList.add(tra);
    }

    public void insertLanguagePair() {
    	Language_Pair__c lp = new Language_Pair__c();
    	lp.Translator__c = getTranslator().id;
    	lp.From__c = languageList[languageList.size()-1].Id;
    	lp.To__c = languageList[languageList.size()-2].Id;
    	insert lp;
    	languagePairList.add(lp);
    }

    // initializers
    public void initializeLanguageWithPricing() {
		insertPricing();
		insertRegionPricing();
		insertLanguage();
    }
    public void initializeCustomSettings() {
    	ReflexSettings.setSettingValue('DAYS_BEFORE_DUE_DATE', '2');
    	ReflexSettings.setSettingValue('MAXIMUM_CHARS_PER_DAY', '6000');
		ReflexSettings.setSettingValue('MAXIMUM_CHARS_PER_DAY_URGENT', '12000');
		ReflexSettings.setSettingValue('MAXIMUM_WORDS_PER_DAY', '500');
		ReflexSettings.setSettingValue('MAXIMUM_WORDS_PER_DAY_URGENT', '1000');
		ReflexSettings.setSettingValue('MINIMUM_CUSTOMER_PRICE_HU', '1000');
		ReflexSettings.setSettingValue('MINIMUM_CUSTOMER_PRICE_INT', '20');
    }

    public void initializeTranslation() {
		initializeLanguageWithPricing();
		insertLanguage();
		insertAccount();
		insertTranslation(); 	
    }

    // asserts
 	public void assertLanguageCount(Integer expectedCount) {
        system.assertEquals(expectedCount, [
            SELECT count()
              FROM Language__c
             WHERE Id in :languageList
        ]);
    }

 	public void assertPricingCount(Integer expectedCount) {
        system.assertEquals(expectedCount, [
            SELECT count()
              FROM Pricing__c
             WHERE Id in :pricingList
        ]);
    }

 	public void assertRegionPricingCount(Integer expectedCount) {
        system.assertEquals(expectedCount, [
            SELECT count()
              FROM Region_Pricing__c
             WHERE Id in :regionPricingList
        ]);
    }

 	public void assertAccountCount(Integer expectedCount) {
        system.assertEquals(expectedCount, [
            SELECT count()
              FROM Account
             WHERE Id in :accountList
        ]);
    }   

 	public void assertTranslationCount(Integer expectedCount) {
        system.assertEquals(expectedCount, [
            SELECT count()
              FROM Translation__c
             WHERE Id in :translationList
        ]);
    }  
}