// Test: ContentDocumentLinkServiceTest
trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, before update, after insert, after update) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('ContentDocumentLink')){
        ContentDocumentLinkTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}