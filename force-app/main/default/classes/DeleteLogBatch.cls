// Test: DeleteLogBatchTest
global inherited sharing class DeleteLogBatch implements Database.Batchable<sObject>, Schedulable {

    String query = 'SELECT Id'
                  + ' FROM Log__c'
                 + ' WHERE CreatedDate < LAST_N_DAYS:30'
              + ' ORDER BY CreatedDate';

    global DeleteLogBatch() {}

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Log__c> scope) {

        for (Database.DeleteResult result_i : Database.delete(scope, false)) {
            if (!result_i.isSuccess()) {
                System.debug('The error occurred while deleting Log: ' + result_i.getErrors());
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new DeleteLogBatch(), 50);
    }
}