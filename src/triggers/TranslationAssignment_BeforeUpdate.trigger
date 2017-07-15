trigger TranslationAssignment_BeforeUpdate on Translation_Assignment__c (before update) {
    new TranslationAssignment_Rejected(trigger.old, trigger.new).execute();
}