//Test: TaskTriggerTest
trigger TaskTrigger on Task (before insert, before update, after insert, after update) {
    
    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('Task')){
        TaskTriggerHandler.handleTrigger(Trigger.new, Trigger.operationType);
    }
}