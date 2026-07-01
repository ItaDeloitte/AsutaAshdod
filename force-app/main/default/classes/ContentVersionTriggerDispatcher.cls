//Test: ContentVersionTest
public with sharing class ContentVersionTriggerDispatcher {

    public static void updateDocFields(List<ContentVersion> newList, Map<Id, ContentVersion> oldMap) {
        System.debug('ContentVersionTriggerDispatcher.updateDocFields...');
        Map<Id, ContentVersion> versionByDocIdMap = new Map<Id, ContentVersion>();

        for (ContentVersion version_i : newList) {
            if (
                version_i.GateScaner_FileScanStatus__c != oldMap.get(version_i.Id).GateScaner_FileScanStatus__c ||
                version_i.GateScaner_Status__c != oldMap.get(version_i.Id).GateScaner_Status__c
            ) {
                versionByDocIdMap.put(version_i.ContentDocumentId, version_i);
            }
        }
        System.debug('versionByDocIdMap: size: ' + versionByDocIdMap.size() + ' value: ' + versionByDocIdMap);

        if (!versionByDocIdMap.isEmpty()) {
            List<File__c> filesToUpdate = new List<File__c>();

            for (File__c file_i : [SELECT Id, GateScaner_Status__c, GateScaner_FileScanStatus__c, Content_Version_Id__c FROM File__c
                                   WHERE Content_Version_Id__c IN: versionByDocIdMap.keySet() AND IsMaccabi__c = false AND CreatedDate = TODAY]) {
                file_i.GateScaner_FileScanStatus__c = versionByDocIdMap.get(file_i.Content_Version_Id__c).GateScaner_FileScanStatus__c;
                file_i.GateScaner_Status__c = versionByDocIdMap.get(file_i.Content_Version_Id__c).GateScaner_Status__c;
                filesToUpdate.add(file_i);
            }
            System.debug('filesToUpdate: size: ' + filesToUpdate.size() + ' value: ' + filesToUpdate);

            for (Database.SaveResult result_i : Database.update(filesToUpdate, false)) {
                if (result_i.isSuccess()) {
                    System.debug('Successfully updated file. File ID is : ' + result_i.getId());
                } else {
                    for (Database.Error error_i : result_i.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(error_i.getStatusCode() + ': ' + error_i.getMessage());
                        System.debug('File__c oject field which are affected by the error:' + error_i.getFields());
                    }
                }
            }
        }
    }
}