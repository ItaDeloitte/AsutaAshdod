trigger GuidanceScenarioTrigger on Guidance_Scenario__c (before insert, before update) {
    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('GuidanceScenarioTrigger')){
        GuidanceScenarioTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}