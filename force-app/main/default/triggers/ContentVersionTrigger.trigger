//Test:ContentVersionTest
trigger ContentVersionTrigger on ContentVersion (after insert, after update) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('ContentVersion')){
        ContentVersionTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}