// Test: RecommendExamServicesTest
trigger RecommendExamTrigger on Recommendations_after_exam__c (after insert, after update) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('Recommendations_after_exam__c')){
        RecommendExamTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}