// Test: AccountServicesTest
trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if (TriggerSetting.isTriggerActive('Account')) {
        AccountTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap);
    }
}