public with sharing class RelatedDocumentTriggerHandler {

    public static void handleTrigger(List<Related_document__c> newList, Map<Id, Related_document__c> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('RelatedDocumentTriggerHandler.handleTrigger...');

        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                RelatedDocumentTriggerDispatcher.checkDuplicateRecords(newList, null);
            }
            when BEFORE_UPDATE {
                System.debug('BEFORE_UPDATE');
                RelatedDocumentTriggerDispatcher.checkDuplicateRecords(newList, oldMap);
            }
        }
    }
}