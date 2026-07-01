// Test: FileTriggerTest
// Created: Yulia Liberman
// Date: 17.06.2020
public class FileTriggerHandler {

    public static void handleTrigger(List<File__c> newList, Map<Id, File__c> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('FileTriggerHandler.handleTrigger...');

        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                FileTriggerDispatcher.preventDuplicateCreation(newList, null);
                FileTriggerDispatcher.fillLookups(newList, null);
                FileTriggerDispatcher.updateFileName(newList, null);
            }
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                FileTriggerDispatcher.updateStatusForReqDocument(newList, null);
            }
            when BEFORE_UPDATE {
                System.debug('BEFORE_UPDATE');
                FileTriggerDispatcher.preventDuplicateCreation(newList, oldMap);
                FileTriggerDispatcher.fillLookups(newList, oldMap);                
                FileTriggerDispatcher.initDoctorPhoto(newList, oldMap);
                FileTriggerDispatcher.markForwardToRIS(newList, oldMap);
                FileTriggerDispatcher.updateFileName(newList, oldMap);
            }
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
                FileTriggerDispatcher.markFileForDeletion(newList, oldMap);
                FileTriggerDispatcher.updatePortalURL(newList, oldMap);
                FileTriggerDispatcher.insertDocumentToPortal(newList, oldMap);
                FileTriggerDispatcher.updateStatusForReqDocument(newList, oldMap);
            }
        }
    }
}