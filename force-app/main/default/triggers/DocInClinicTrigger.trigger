// Test: DocInClinicServicesTest
// Created: Evgeniy Kravchuk
// Date: 30.01.2020
trigger DocInClinicTrigger on Doctor_in_Clinic__c (before insert, after insert, after update, after delete) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('Doctor_in_Clinic__c')){
        DocInClinicTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}