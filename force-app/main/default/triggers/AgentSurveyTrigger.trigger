// Test: AgentSurveyTriggerDispatcherTest
trigger AgentSurveyTrigger on Agent_survey__c (before insert, before update, after insert, after update) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('Agent_survey__c')){
        AgentSurveyTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}