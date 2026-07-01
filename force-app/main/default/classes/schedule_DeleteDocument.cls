// Test: schedule_DeleteDocumentTest
global with sharing class schedule_DeleteDocument implements Database.Batchable<sObject>, Schedulable {

    String query = 'SELECT Id , Content_Version_Id__c'
                  + ' FROM File__c'
                  + ' WHERE Content_Version_Id__c != null'
                  + ' AND (URL__c != null OR GateScaner_FileScanStatus__c = \'1\' OR GateScaner_FileScanStatus__c = \'3\')'
                  + ' AND CreatedDate > LAST_N_MONTHS:1'
              + ' ORDER BY CreatedDate';

    global schedule_DeleteDocument() {}

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<File__c> scope) {
        List<ContentDocument> docsToRemove = new List<ContentDocument>();
        Map<String, File__c> fileByDocId = new Map<String, File__c>();
        List<File__c> filesToUpdate = new List<File__c>();
        Set<String> docIds = new Set<String>();

        for (File__c file_i : scope) {
            fileByDocId.put(file_i.Content_Version_Id__c, file_i);
            docIds.add(file_i.Content_Version_Id__c);
            file_i.Content_Version_Id__c = null;
            //filesToUpdate.add(file_i);
        }
        System.debug('fileByDocId: size: ' + fileByDocId.size() + ' value: ' + fileByDocId);
        System.debug('docIds: size: ' + docIds.size() + ' value: ' + docIds);

        for (ContentVersion cv_i : [SELECT ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: docIds AND IsNeedToBeDeleted__c = true]){
            docsToRemove.add(new ContentDocument(Id = cv_i.ContentDocumentId));
        }
        System.debug('docsToRemove: size: ' + docsToRemove.size() + ' value: ' + docsToRemove);

        for (Database.DeleteResult result_i : Database.delete(docsToRemove, false)) {
            if (result_i.isSuccess() && fileByDocId.containsKey(result_i.getId())) {
                filesToUpdate.add(fileByDocId.get(result_i.getId()));
            } else {
                System.debug('The error occurred while deleting Content Document: ' + result_i.getErrors());
            }
        }
        System.debug('filesToUpdate: size: ' + filesToUpdate.size() + ' value: ' + filesToUpdate);

        for (Database.SaveResult result_i : Database.update(filesToUpdate, false)) {
            if (!result_i.isSuccess()) {
                System.debug('The error occurred while updating File: ' + result_i.getErrors());
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new schedule_DeleteDocument(), 25);
    }
}