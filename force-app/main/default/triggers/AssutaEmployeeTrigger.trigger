trigger AssutaEmployeeTrigger on Assuta_Employee__c (before insert, before update, after insert, after update) {
	TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('Assuta_Employee__c')){
        AssutaEmployeeTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}