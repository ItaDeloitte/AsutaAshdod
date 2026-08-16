// Test: RecommendTypeServicesTest
trigger RecommendTypeTrigger on RecommendationsTypeAfterExam__c (after insert, after update) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('RecommendationsTypeAfterExam__c')){
        RecommendTypeTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}