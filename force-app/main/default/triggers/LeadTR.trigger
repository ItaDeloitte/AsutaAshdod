// Test: LeadTRTest
trigger LeadTR on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if (TriggerSetting.isTriggerActive('Lead')) {
        LeadTRHandler.handleTrigger(Trigger.new, Trigger.oldMap);
    }
}