trigger RelatedDocumentTrigger on Related_document__c (before insert, after insert, before update, after update) {
    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('Related_document__c')){
    	RelatedDocumentTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}