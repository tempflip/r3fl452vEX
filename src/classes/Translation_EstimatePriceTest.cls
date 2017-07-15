@isTest
private with sharing class Translation_EstimatePriceTest {

	static testMethod void myTest1() {
		ReflexTests test = new ReflexTests();

		test.initializeLanguageWithPricing();
		

		update test.getPricing();
        
		test.initializeTranslation();
        test.insertLanguage();
        test.insertLanguage();
        test.getPricing().Language_From__c = test.languageList[0].id;
        test.getPricing().Language_To__c = test.languageList[1].id;
        update test.getPricing();
        
        test.insertAccountPricing();
        test.getAccountPricing().Source_Language__c = test.languageList[0].id;
        test.getAccountPricing().Target_Language__c = test.languageList[1].id;
        test.getAccountPricing().Account__c = test.getTranslation().Account__c;
        update test.getAccountPricing();
        
        test.getTranslation().Source_Language__c = test.languageList[0].id;
        test.getTranslation().Target_Language__c = test.languageList[1].id;
        test.getTranslation().Estimated_Count__c = 1998;
        update test.getTranslation();
       
        system.assert(test.getTranslation().Account__c == test.getAccountPricing().Account__c);
          
		system.assert(true);
	}
}