// Test: GateScannerFileServiceTest
public without sharing class GateScannerFileTriggerDispatcher {

        public static void restoreLocation(List <GateScanner_file__c> newList, Map <Id, GateScanner_file__c> oldMap) {
            System.debug('GateScannerFileTriggerDispatcher.restoreLocation...');

            List<GateScanner_file__c> filesToRestoreList = new List<GateScanner_file__c>();

            for (GateScanner_file__c file_i : newList) {
                if (file_i.Status__c == 'Scanning passed' && file_i.Status__c != oldMap.get(file_i.id).Status__c) {
                    filesToRestoreList.add(file_i);
                }
            }

            if (!filesToRestoreList.isEmpty()) {
                GateScannerFileService.restoreFileLocation(filesToRestoreList);
            }
        }
}