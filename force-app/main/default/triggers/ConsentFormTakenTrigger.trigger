trigger ConsentFormTakenTrigger on ConsentFormTaken__c (before insert, after insert) {
    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('ConsentFormTaken')){
        ConsentFormTakenTriggerHandler.handleTrigger(Trigger.new, Trigger.operationType);
    }
}