// Test: GateScannerFileServiceTest
// author: anatoly voronov (anatoly.voronov@synebo.io)
// created date : 06.06.2019
public without sharing class GateScannerFileTriggerHandler {

    public static void handleTrigger(List<GateScanner_file__c> newList, Map <id, GateScanner_file__c> oldMap, System.TriggerOperation triggerEvent) {
        System.debug('GateScannerFileTriggerHandler.handleTrigger...');

           switch on triggerEvent {
               when AFTER_UPDATE {
                   System.debug('AFTER_UPDATE');
                   GateScannerFileTriggerDispatcher.restoreLocation(newList, oldMap);
                }
            }
    }
}