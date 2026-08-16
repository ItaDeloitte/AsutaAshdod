//Test: DisabilityServicesTest
trigger DisabilityTrigger on Disabilities__c (after insert, after update, after delete) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('Disabilities__c')){
        DisabilityTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}