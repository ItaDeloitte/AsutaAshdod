// Test: SequenceTRTest
trigger SequenceTR on Sequence__c (before insert, after insert, before update, after update) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if (TriggerSetting.isTriggerActive('Sequence__c')) {
        SequenceTRHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.newMap, Trigger.operationType);
    }
}