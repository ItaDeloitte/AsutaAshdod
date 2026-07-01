// Test: DocMedProcedureServicesTest
// Created: Evgeniy Kravchuk
// Date: 26.12.2019
trigger DocMedProcedureTrigger on Doctor_Medical_Procedure__c (after insert, after delete) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('Doctor_Medical_Procedure__c')){
        DocMedProcedureTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}