//Test Class:CaseMassUpdateBatchTest
global with sharing class CaseMassUpdateBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('CaseMassUpdateBatch ... start');
        return Database.getQueryLocator([
            SELECT Id, TimestampForBatchProcess__c                 
            FROM Case 
            WHERE TimestampForBatchProcess__c = null 
            AND CreatedDate != THIS_WEEK
            ORDER BY CreatedDate ASC LIMIT 50000
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        for (Case case_i : scope) {
            case_i.TimestampForBatchProcess__c = System.now();
        }
        TriggerHandler.bypass('CaseTriggerHandler');
        List<Database.SaveResult> result = Database.update(scope, false);
        TriggerHandler.clearBypass('CaseTriggerHandler');
    }

    global void finish(Database.BatchableContext BC) {

    }
}