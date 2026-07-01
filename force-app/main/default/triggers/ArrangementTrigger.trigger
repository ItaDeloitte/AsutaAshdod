trigger ArrangementTrigger on Arrangements__c (after update) {
    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('ArrangementTrigger')){
        ArrangementTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}