trigger OpportunityTrigger on Opportunity (before insert) {
	TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('Opportunity')){
        OpportunityTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}