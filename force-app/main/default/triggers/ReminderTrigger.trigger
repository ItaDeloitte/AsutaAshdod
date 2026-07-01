//Test: ws_TizkuritTest
trigger ReminderTrigger on Reminder__c (after insert, after update) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if (TriggerSetting.isTriggerActive('Reminder__c')) {
        ReminderTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}