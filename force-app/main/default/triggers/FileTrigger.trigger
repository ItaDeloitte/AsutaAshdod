trigger FileTrigger on File__c (before insert, after insert, before update, after update) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if (TriggerSetting.isTriggerActive('FileTrigger')){
        FileTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}