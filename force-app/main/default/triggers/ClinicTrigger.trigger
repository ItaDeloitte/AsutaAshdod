// Test: ClinicServicesTest
// Created: Evgeniy Kravchuk
// Date: 31.01.2020
trigger ClinicTrigger on Clinic__c (after insert, after update, after delete) {
    
    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('Clinic__c')){
        ClinicTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}