// Test: GateScannerFileServiceTest
trigger GateScannerFileTrigger on GateScanner_file__c (before insert, before update, after insert, after update) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('GateScanner_file__c')){
        GateScannerFileTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}