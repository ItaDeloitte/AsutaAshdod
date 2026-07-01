// Test: ContentDocumentLinkServiceTest
// author: anatoly voronov (anatoly.voronov@synebo.io)
// created date : 05.06.2019
public without sharing class ContentDocumentLinkTriggerHandler {

    public static void handleTrigger(List<ContentDocumentLink> newList, Map<Id, ContentDocumentLink> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('ContentDocumentLinkTriggerHandler.handleTrigger...');
        switch on triggerEvent {
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                ContentDocumentLinkTriggerDispatcher.createFileAndSendToScan(newList);
                ContentDocumentLinkTriggerDispatcher.createLinkForRelatedDocument(newList);
            }
        }
    }
}