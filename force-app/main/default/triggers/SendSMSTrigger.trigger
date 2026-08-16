//Test: SendSMSHandlerTest
trigger SendSMSTrigger on SMS__c (after insert, before insert, after update) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('SMS__c')){
        SMSTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}