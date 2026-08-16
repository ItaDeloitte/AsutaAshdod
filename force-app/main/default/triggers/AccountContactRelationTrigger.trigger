// Test: AccConRelationServicesTest
trigger AccountContactRelationTrigger on AccountContactRelation (before insert, after insert, after update, after delete) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('AccountContactRelation')){
        AccContactRelationTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }   
}