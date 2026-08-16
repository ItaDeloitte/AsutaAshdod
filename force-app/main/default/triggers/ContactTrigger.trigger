// Test: ContactServicesTest
// Created: Evgeniy Kravchuk
// Date: 27.05.2019
trigger ContactTrigger on Contact (before insert, before update) {
    
    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('Contact')){
        ContactTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}