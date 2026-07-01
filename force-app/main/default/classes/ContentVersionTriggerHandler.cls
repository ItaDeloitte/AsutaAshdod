//Test: ContentVersionTest
public without sharing class ContentVersionTriggerHandler {

    public static void handleTrigger(List<ContentVersion> newList, Map<Id, ContentVersion> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('ContentDocumentLinkTriggerHandler.handleTrigger...');
        switch on triggerEvent {
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
                ContentVersionTriggerDispatcher.updateDocFields(newList, oldMap);
            }
        }
    }
}