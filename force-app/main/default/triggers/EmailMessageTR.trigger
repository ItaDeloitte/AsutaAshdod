// Test: EmailMessageTRTest
trigger EmailMessageTR on EmailMessage (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if (TriggerSetting.isTriggerActive('EmailMessage')) {
        EmailMessageTRHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}